require 'sinatra'
require 'sinatra/base'
require 'sinatra/reloader'
require 'sequel'
require 'sqlite3'
require_relative 'error'

class MainApp < Sinatra::Base
  set :environment, :devleopment
  #enable :seessions
  use Rack::Session::Cookie

  db = Sequel.sqlite('bbs.db')
  master = db[:sqlite_master]
  if master.where("type='table' and name='thread'").count == 0
    db.create_table :thread do
      primary_key :thread_id
      String :name
      String :title
      String :text
      String :write_date
      String :post_username
    end
  end
  if master.where("type='table' and name='account'").count == 0
    db.create_table :account do
      primary_key :id
      String :login_user
      String :login_password
    end
  end

  before do
    @items = db[:thread]
    @account = db[:account]
  end


  get '/' do
    erb :login
  end

  get '/create_account' do
    erb :create_account
  end

  get '/edit_account?' do
    erb :edit_account
  end

  get '/delete_account?' do
    @current_login_user = session[:user_id]
    erb :delete_account
  end

  get '/main' do
    @threads = @items.order(Sequel.desc(:write_date)).limit(10)
    @pagination = page_count
    @user = session[:user_id]
    erb :main
  end

  get '/page/:number' do
    number = params['number'].to_i * 10
    front = 0
    back =0
    if number == 10
      front = 1
      back = number
    else
      front = number -9
      back = number
    end
    contens = @items.order(Sequel.desc(:write_date)).all
    f = front-1
    b = back-1
    @threads = contens[f..b]
    @pagination = page_count
    erb :main
  end

  post '/main' do
    exist_account =  @account.where(login_user: params[:login_user]).where(login_password: params[:login_password]).count
    if exist_account.to_i == 1
      session[:user_id] = params['login_user']
      @threads = @items.order(Sequel.desc(:write_date)).limit(10)
      @pagination = page_count
      @user = session[:user_id]
      erb :main
    else
      raise Error::LoginError, 'not able to log in'
    end
  end

  get '/edit_thread/:id' do
    @thread = @items.where(thread_id: params[:id]).first
    erb :edit_thread
  end

  get '/logout' do
    session.clear
    redirect '/'
  end

  post '/create_account' do
    p params[:login_user]
    p params[:login_password]
    exist_account =  @account.where(login_user: params[:login_user]).count
    if exist_account.to_i == 0
      @account.insert(:login_user => params[:login_user], :login_password => params[:login_password])
    else
      raise ArgumentError.new
    end
    redirect '/'
  end

  post '/edit_account' do
    exist_account =  @account.where(login_user: params[:login_user],login_password: params[:old_login_password]).count
    if exist_account.to_i == 1
      @account.where(login_user: session[:user_id]).update(:login_password => params[:new_login_password])
    else
      raise ArgumentError.new
    end
    redirect '/'
  end

  post '/delete_account' do
    exist_account =  @account.where(login_user: params[:login_user], login_password: params[:login_password]).count
    if exist_account.to_i == 1
      @account.where(login_user: session[:user_id]).delete
    else
      raise ArgumentError.new
    end
    redirect '/'
  end

  post '/create_thread?' do
    @items.insert(:name => params[:name], :title => params[:title], :text => params[:text],
                :write_date => Time.now.strftime("%Y/%m/%d %H:%M:%S"), :post_username => params[:post_username])
    p "name:#{params[:name]} title:#{params[:title]} text:#{params[:text]}"
    redirect '/main'
  end

  post '/edit_thread/:id?' do
    p params[:name]
    p params[:text]
    @items.where(thread_id: params[:id]).update(:name => params['name'], :title => params[:title], :text => params[:text])
    redirect '/main'
  end

  post'/delete_thread/:id?' do
    @items.where(thread_id: params[:id]).delete
    redirect '/main'
  end

  error ArgumentError do
    erb :error
  end

  error Error::LoginError do
    erb :login_error
  end

  def page_count
    count = @items.count
    division = count.divmod(10)
    if division[1] == 0
      d = division[0]
    else
      d = division[0] + 1
    end
    pagination = 1..d
  end
end