require 'sinatra'
require 'json'

get '/top' do
  @h = ''
  File.open('data.json', 'r') do |file|
    memos = JSON.parse(file.read)
    @h += '<ul>'
    memos['memos'].each do |data|
      @h += "<li><a href='http://localhost:4567/#{data['id']}/show-memo'>#{data['title']}</a></li>"
    end
    @h += '</ul>'
  end
  erb :index
end

get '/newMemo' do
  erb :newMemo
end

post '/new/create' do
  max_id = 0
  memos = JSON.parse(File.read('data.json'))
  memos['memos'].each do |memo|
    max_id = memo['id'].to_i if max_id < memo['id'].to_i
  end
  p max_id
  new_data = { "id": (max_id + 1).to_s, "title": h(params[:title]), "body": h(params[:body]) }
  memos['memos'].push(new_data)
  File.write('data.json', memos.to_json)
  redirect '/top'
end

get '/:id/show-memo' do
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
      memo['title'] = h(params[:title])
      memo['body'] = h(params[:body])
    end
  end
  File.write('data.json', memos.to_json)
  redirect '/top'
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
  redirect '/top'
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
