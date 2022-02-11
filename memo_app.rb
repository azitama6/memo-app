# frozen_string_literal: true

require 'sinatra'
require 'json'
require 'pg'
require 'dotenv'

Dotenv.load

# 環境変数確認
p ENV["DB_HOST"]
p ENV["DB_PASS"]
p ENV["DB_USER"]
p ENV["DB_NAME"]
p ENV["DB_PORT"]
p ENV["TABLE_NAME"]

class Memo
  class << self
    def find_memo(connection, id)
      memos = connection.exec("SELECT * FROM #{ENV["TABLE_NAME"]} WHERE id = #{id} ").map{|row| row }
      memos.find { |memo| memo['id'] == id.to_s }
    end

    def create_memo(connection, title, body)
      connection.exec("INSERT INTO #{ENV["TABLE_NAME"]} (title, body) VALUES(#{title}, #{body})")
    end

    def delete_memo(connection, id)
      connection.exec("DELETE FROM #{ENV["TABLE_NAME"]} WHERE id = #{id} ")
    end

    def update_memo(connection, id, title, body)
      connection.exec("UPDATE #{ENV["TABLE_NAME"]} SET title = #{title}, body = #{body} WHERE id = #{id} ")
    end
  end
end

connection = PG::connect(host: ENV["DB_HOST"], password: ENV["DB_PASS"], user: ENV["DB_USER"], dbname: ENV["DB_NAME"], port: ENV["DB_PORT"])

get '/' do
  @memos = JSON.parse(File.read('data.json'))
  erb :index
end

get '/memos/new' do
  erb :newMemo
end

post '/memos' do
  max_id = 0
  memos = JSON.parse(File.read('data.json'))
  memos['memos'].each do |memo|
    max_id = memo['id'].to_i if max_id < memo['id'].to_i
  end
  new_data = { "id": (max_id + 1).to_s, "title": params[:title], "body": params[:body] }
  memos['memos'].push(new_data)
  File.write('data.json', memos.to_json)
  redirect '/'
end

get '/memos/:id' do
  @title = ''
  @body = ''
  find_data = Memo.find_memo(connection, params[:id])
  @memo = find_data unless find_data.empty?
  erb :showMemo
end

get '/editMemo/:id' do
  @title = ''
  @body = ''
  find_data = Memo.find_memo(connection, params[:id])
  @memo = find_data unless find_data.empty?
  erb :editMemo
end

patch '/editMemo/:id/update' do
  memos = JSON.parse(File.read('data.json'))
  memos['memos'].each do |memo|
    if memo['id'] == params[:id]
      memo['title'] = params[:title]
      memo['body'] = params[:body]
    end
  end
  File.write('data.json', memos.to_json)
  redirect '/'
end

delete '/delete/:id' do
  new_hash = {}
  new_array = []
  memos = JSON.parse(File.read('data.json'))
  memos['memos'].each do |memo|
    new_array.push(memo) if memo['id'] != params[:id]
    new_hash = { 'memos': new_array }
  end
  File.write('data.json', new_hash.to_json)
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
