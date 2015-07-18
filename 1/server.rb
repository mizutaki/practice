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
items = db[:thread]
items.insert(:name => 'abc',:title => 'aaaa', :text => '888', :write_date => Time.now)

get '/' do
  erb :index
end
