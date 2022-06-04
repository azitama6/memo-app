# frozen_string_literal: true

require 'sinatra'
require 'json'
require 'pg'
require 'dotenv'

Dotenv.load

# MemoClass for Run SQL
class Memo
  class << self
    def connection
      @connection ||= PG.connect(
        host: ENV['DB_HOST'],
        password: ENV['DB_PASS'],
        user: ENV['DB_USER'],
        dbname: ENV['DB_NAME'],
        port: ENV['DB_PORT']
      )
    end

    def show
      connection.exec('SELECT * FROM memo ORDER BY id')
    end

    def find(id)
      connection.exec('SELECT * FROM memo WHERE id = $1 ORDER BY id', [id])[0]
    end

    def create(title, body)
      connection.exec('INSERT INTO memo (title, body) VALUES ($1, $2)', [title, body])
    end

    def delete(id)
      connection.exec('DELETE FROM memo WHERE id = $1', [id])
    end

    def update(id, title, body)
      connection.exec('UPDATE memo SET title = $1, body = $2 WHERE id = $3', [title, body, id])
    end
  end
end

get '/' do
  @memos = Memo.show
  erb :index
end

get '/memos/new' do
  erb :newMemo
end

post '/memos' do
  Memo.create(params[:title], params[:body])
  redirect '/'
end

get '/memos/:id' do
  @memo = Memo.find(params[:id])
  erb :showMemo
end

get '/editMemo/:id' do
  @memo = Memo.find(params[:id])
  erb :editMemo
end

patch '/editMemo/:id/update' do
  Memo.update(params[:id], params[:title], params[:body])
  redirect '/'
end

delete '/delete/:id' do
  Memo.delete(params[:id])
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
