require 'sinatra'
require 'sinatra/base'
require 'sinatra/reloader'
require_relative 'db'
require_relative 'error'

class MainApp < Sinatra::Base
  set :environment, :devleopment
  use Rack::Session::Cookie
  set :public, File.dirname(__FILE__) + '/public'

  before do
    @db = DB.new
  end

  helpers do
    def page_count
      count = @db.thread_max_count
      division = count.divmod(10)
      if division[1] == 0
        d = division[0]
      else
        d = division[0] + 1
      end
      pagination = 1..d
    end

    def create_imagefiles(threads)
      threads.each do |thread|
        unless thread[:attachment_file_path] == nil
          File.open("./public/images/" + thread[:attachment_file_path], "wb") do |w|
            w.write thread[:attachment_file]
          end
        end
      end
    end
  end

  get '/' do
    erb :login
  end

  get '/create_account' do
    erb :'account/create_account'
  end

  get '/edit_account?' do
    erb :'account/edit_account'
  end

  get '/delete_account?' do
    @current_login_user = session[:user_id]
    erb :'account/delete_account'
  end

  get '/main' do
    @threads = @db.get_threads(10)
    create_imagefiles(@threads)
    @pagination = page_count
    @user = session[:user_id]
    erb :'main/index'
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
    contens = @db.get_threads(nil)
    f = front-1
    b = back-1
    @threads = contens[f..b]
    @pagination = page_count
    erb :'main/index'
  end

  post '/main' do
    exist_account =  @db.exist_account(params[:login_user], params[:login_password])
    if exist_account
      session[:user_id] = params['login_user']
      @threads = @db.get_threads(10)
      create_imagefiles(@threads)
      @pagination = page_count
      @user = session[:user_id]
      erb :'main/index'
    else
      raise Error::LoginError, 'not able to log in'
    end
  end

  get '/edit_thread/:id' do
    @thread = @db.get_thread(params[:id])
    erb :'thread/edit_thread'
  end

  get '/logout' do
    session.clear
    redirect '/'
  end

  post '/create_account' do
    exist_account = @db.exist_account(params[:login_user], params[:login_password])
    unless exist_account
      @db.insert_account(params)
    else
      raise ArgumentError.new, 'not create account'
    end
    redirect '/'
  end

  post '/edit_account' do
    exist_account = @db.exist_account(params[:login_user], params[:old_login_password])
    if exist_account
      @db.update_account(session[:user_id], params[:new_login_password])
    else
      raise ArgumentError.new, 'not edit account'
    end
    redirect '/'
  end

  post '/delete_account' do
    exist_account = @db.exist_account(params[:login_user], params[:login_password])
    if exist_account
      @db.delete_account(session[:user_id])
    else
      raise ArgumentError.new, 'not delete account'
    end
    redirect '/'
  end

  post '/create_thread?' do
    file = params["file"]
    unless file == nil
      file_path = File.basename(file[:tempfile].path)
      blob = Sequel.blob(File.read(file[:tempfile]))
    end
    @db.insert_thread(params, blob, file_path)
    redirect '/main'
  end

  post '/edit_thread/:id?' do
    @db.update_thread(params)
    redirect '/main'
  end

  post'/delete_thread/:id?' do
    @db.delete_thread(params)
    redirect '/main'
  end

  error ArgumentError do
    @error_message = params[:captures].first
    erb :'error/error'
  end

  error Error::LoginError do
    @error_message = params[:captures].first
    erb :'error/login_error'
  end
end