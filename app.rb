#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
 @db = SQLite3::Database.new 'leprosorium.db'
 @db.results_as_hash = true
end

before do
	init_db	
end

configure do
	init_db 
	@db.execute 'CREATE TABLE IF NOT EXISTS "Posts" 
	(
		"id" INTEGER PRIMARY KEY, 
		"created_date" DATE, 
		"content" TEXT
	)'
end

get '/' do
	#выбираем список постов из db
	@results = @db.execute 'select * from Posts order by id desc'
	
	erb :index
end

get '/new' do
	erb :new
end

post '/new' do
	@content = params[:content]

	if @content.length <= 0
		@error = 'Type text'
		return erb :new
	end

	#сохранене данных в db

	@db.execute 'insert into Posts
	(
		content,
		created_date
	) 
	values ( ?, datetime())', [@content]
	
	#перенаправление на главную
	redirect to '/'
end

#вывод инф о посте

get '/details/:post_id' do
	post_id = params[:post_id]

	results = @db.execute 'select * from Posts where id = ?', [post_id]
	@row = results[1]

	erb :details
end