# frozen_string_literal: true

require 'sinatra'
require 'json'

get '/' do
  File.open('data.json', 'r') do |file|
    @memos = JSON.parse(file.read)
  end
  erb :index
end

get '/memos/new' do
  erb :newMemo
end

post '/memos/create' do
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
  File.open('data.json', 'r') do |file|
    memos = JSON.parse(file.read)
    find_data = memos['memos'].find { |item| item['id'] == params[:id].to_s }
    if find_data != ''
      @id = find_data['id']
      @title = find_data['title']
      @body = find_data['body']
    end
  end
  erb :showMemo
end

get '/editMemo/:id' do
  @title = ''
  @body = ''
  File.open('data.json', 'r') do |file|
    memos = JSON.parse(file.read)
    find_data = memos['memos'].find { |item| item['id'] == params[:id].to_s }
    if find_data != ''
      @id = find_data['id']
      @title = find_data['title']
      @body = find_data['body']
    end
  end
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
