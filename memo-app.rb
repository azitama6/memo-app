require 'sinatra'
require 'json'

get '/top' do
  @h = ''
  File.open('data.json', 'r') do |file|
    memos = JSON.parse(file.read)
    @h += '<ul>'
    memos['memos'].each do |data|
      # puts data["title"]
      @h += "<li><a href='http://localhost:4567/top'>#{data['title']}</a></li>"
    end
    @h += '</ul>'
  end
  erb :index
end

get '*' do
  redirect '/top'
end
