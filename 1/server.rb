require 'sinatra'
require 'sequel'

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

before do
  @items = db[:thread]
end

get '/' do
  @threads = @items.all
  erb :index
end

get '/create_thread' do
  erb :create_thread
end

get '/edit_thread/:id' do
  @thread = @items.where(id: params[:id]).first
  erb :edit_thread
end

post '/create_thread?' do
  @items.insert(:name => params[:name], :title => params[:title], :text => params[:text], :write_date => Time.now)
  p "name:#{params[:name]} title:#{params[:title]} text:#{params[:text]}"
  redirect '/'
end

post '/edit_thread/:id?' do
  @items.where(id: params[:id]).update(:name => params['name'], :title => params[:title], :text => params[:text])
  redirect '/'
end

post'/delete_thread/:id?' do
  @items.where(id: params[:id]).delete
  redirect '/'
end
