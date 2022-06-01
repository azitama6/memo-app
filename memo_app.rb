# frozen_string_literal: true

require 'sinatra'
require 'json'
require 'pg'
require 'dotenv'

Dotenv.load

class Memo
  class << self
    def connection
      PG::connect(host: ENV["DB_HOST"], password: ENV["DB_PASS"], user: ENV["DB_USER"], dbname: ENV["DB_NAME"], port: ENV["DB_PORT"])
    end

    def all_memo
      connection.exec("SELECT * FROM MEMO ORDER BY ID")
    end

    def find_memo(id)
      memos = connection.exec("SELECT * FROM MEMO WHERE id = '#{id}' ORDER BY ID")
      memos.find { |memo| memo['id'] == id.to_s }
    end

    def create_memo(title, body)
      connection.exec("INSERT INTO MEMO (title, body) VALUES(\'#{title}\', \'#{body}\') ")
    end

    def delete_memo(id)
      connection.exec("DELETE FROM MEMO WHERE id = #{id} ")
    end

    def update_memo(id, title, body)
      connection.exec("UPDATE MEMO SET title = \'#{title}\', body = \'#{body}\' WHERE id = #{id} ")
    end
    connection.finish
  end
end



get '/' do
  @memos = Memo.all_memo
  erb :index
end

get '/memos/new' do
  erb :newMemo
end

post '/memos' do
  Memo.create_memo(params[:title], params[:body])
  redirect '/'
end

get '/memos/:id' do
  @memo = Memo.find_memo(params[:id])
  erb :showMemo
end

get '/editMemo/:id' do
  @memo = Memo.find_memo(params[:id])
  erb :editMemo
end

patch '/editMemo/:id/update' do
  Memo.update_memo(params[:id], params[:title], params[:body])
  redirect '/'
end

delete '/delete/:id' do
  Memo.delete_memo(params[:id])
  redirect '/'
end

get '/page-notfound' do
  erb :notFound
end

get '*' do
  redirect '/page-notfound'
end

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end
