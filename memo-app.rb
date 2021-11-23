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

get '/:id/show-memo' do
  @title = ''
  @body = ''
  p params[:id].to_s
  File.open('data.json', 'r') do |file|
    memos = JSON.parse(file.read)
    find_data = memos['memos'].find { |item| item['id'] == params[:id].to_s }
    p find_data
    if find_data != ''
      @id = find_data['id']
      @title = find_data['title']
      @body = find_data['body']
    end
  end
  erb :showMemo
end

post '/editMemo/:id' do
  @title = ''
  @body = ''
  p params[:id].to_s
  File.open('data.json', 'r') do |file|
    memos = JSON.parse(file.read)
    find_data = memos['memos'].find { |item| item['id'] == params[:id].to_s }
    p find_data
    if find_data != ''
      @id = find_data['id']
      @title = find_data['title']
      @body = find_data['body']
    end
  end
  erb :editMemo
end

post '/editMemo/:id/update' do
  File.open('data.json', 'r+') do |file|
    memos = JSON.parse(file.read)
    p result = memos['memos'].map { |item| item['id'] == params[:id].to_s ? params[:title] : item['title'] }
    # mods.map! { |item| item['id'] == params[:id].to_s ? params[:body] : item['body'] }
    # p memos['memos']
    # if memos['memos']
    #  file.write(memos['memos'])
    # end
  end
  redirect '/top'
end

get '/page-notfound' do
  erb :notFound
end

get '*' do
  redirect '/page-notfound'
end
