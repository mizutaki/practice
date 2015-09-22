require 'sequel'
require 'sqlite3'

class DB

  attr_accessor :account, :thread
  def initialize
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
        blob :attachment_file
        string :attachment_file_path
      end
    end
    if master.where("type='table' and name='account'").count == 0
      db.create_table :account do
        primary_key :id
        String :login_user
        String :login_password
      end
    end
    @account = db[:account]
    @thread = db[:thread]
  end

  def exist_account(user_id,user_password)
    exist_account = @account.where(login_user: user_id).where(login_password: user_password).count
    exist_account.to_i == 1
  end

  def insert_account(params)
    @account.insert(:login_user => params[:login_user], :login_password => params[:login_password])
  end

  def update_account(session_user, user_password)
    account = get_sesssion_user(session_user)
    account.update(:login_password => user_password)
  end

  def delete_account(session_user)
    account = get_sesssion_user(session_user)
    account.delete
  end

  def get_threads(limit)
    if limit == nil
      @thread.order(Sequel.desc(:write_date)).all
    else
      @thread.order(Sequel.desc(:write_date)).limit(limit)
    end
  end

  def get_thread(id)
    thread = get_thread_id(id)
    thread.first
  end

  def insert_thread(params,blob,file_path)
    @thread.insert(:name => params[:name], :title => params[:title], :text => params[:text],
                :write_date => Time.now.strftime("%Y/%m/%d %H:%M:%S"), :post_username => params[:post_username], 
                :attachment_file =>blob, :attachment_file_path => file_path)
  end

  def update_thread(params)
    thread = get_thread_id(params[:id])
    thread.update(:name => params[:name], :title => params[:title], :text => params[:text])
  end

  def delete_thread(params)
    thread = get_thread_id(params[:id])
    thread.where(thread_id: params[:id]).delete
  end

  def thread_max_count
    @thread.count
  end

  private
  def get_thread_id(id)
    @thread.where(thread_id: id)
  end

  def get_sesssion_user(session_user)
    @account.where(login_user: session_user)
  end
end