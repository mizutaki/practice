require 'sinatra'
require 'sinatra/reloader'
require 'sequel'

set :environment, :production
#enable :seessions
use Rack::Session::Cookie

db = Sequel.sqlite('bbs.db')
master = db[:sqlite_master]
if master.where("type='table' and name='thread'").count == 0
  db.create_table :thread do
    primary_key :id
    String :name
    String :title
    String :text
    Date :write_date
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
  erb :delete_account
end

post '/main' do
  session[:user_id] = params['login_user']
  p session[:user_id]
  @threads = @items.all
  erb :main
end

get '/edit_thread/:id' do
  @thread = @items.where(id: params[:id]).first
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
  p params[:login_user]
  p params[:login_password]
  exist_account =  @account.where(login_user: params[:login_user]).count
  if exist_account.to_i == 0
    @account.where(session[:user_id]).update(:login_user => params[:login_user], :login_password => params[:login_password])
  else
    raise ArgumentError.new
  end
  redirect '/'
end

post '/delete_account' do
  exist_account =  @account.where(login_user: params[:login_user]).count
  if exist_account.to_i == 1
    @account.where(login_user: session[:user_id]).delete
  else
    raise ArgumentError.new
  end
  redirect '/'
end


post '/create_thread?' do
  @items.insert(:name => params[:name], :title => params[:title], :text => params[:text], :write_date => Time.now)
  p "name:#{params[:name]} title:#{params[:title]} text:#{params[:text]}"
  redirect '/main'
end

post '/edit_thread/:id?' do
  @items.where(id: params[:id]).update(:name => params['name'], :title => params[:title], :text => params[:text])
  redirect '/main'
end

post'/delete_thread/:id?' do
  @items.where(id: params[:id]).delete
  redirect '/main'
end

error ArgumentError do
  erb :error
end
