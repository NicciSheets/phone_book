require 'sinatra'
require 'pg'
require 'securerandom'

load 'local_env.rb' if File.exist?('local_env.rb')

enable :sessions

conn = PG::Connection.open(:host => ENV['DB_HOST'], :user => ENV['DB_USERNAME'], :dbname => ENV['DB_NAME'], :port => ENV['DB_PORT'], :password => ENV['DB_PASSWORD'])

def prepare_statements(conn)
	conn.prepare("ndb", "insert into user_info (uuid, user_id, user_pass) values($1, $2, $3)")
	conn.prepare("cons", "insert into contacts (first_name, last_name, phone, address) values($1, $2, $3, $4)")
end
prepare_statements(conn)

get '/' do
	username = username || ""
	password = password || ""
	password2 = password2 || ""
	erb :login
end

post '/new_user' do
	username = params[:username]
	password = params[:password]
	password2 = params[:password2]

	if password != password2
		redirect '/'
	end

	conn.exec_prepared('ndb', [SecureRandom.uuid, params[:username] , params[:password]])

	res = conn.exec("SELECT * FROM user_info WHERE user_id = '#{username}' AND user_pass = '#{password}' ")

	res.each do |n|
		session[:id] = n['uuid']
		session[:user_name] = n['user_id']
		redirect '/phonebook'
	end
end

post '/existing_user' do
	username = params[:username]
	password = params[:password]

	res = conn.exec("SELECT * FROM user_info WHERE user_id = '#{username}' AND user_pass = '#{password}' ")

	res.each do |n|
		session[:id] = n['uuid']
		session[:user_name] = n['user_id']
		redirect '/phonebook'
	end
end

get '/phonebook' do
	# first_name = first_name || ""
	# last_name = last_name || ""
	# phone = phone || ""
	# address = address || ""
	erb :phonebook
end

post '/phonebook' do
	# first_name = params[:first_name]
	# last_name = params[:last_name]
	# phone = params[:phone]
	# address = params[:address]
	redirect '/phonebook'
end

get '/new_contact' do
	first_name = first_name || ""
	last_name = last_name || ""
	phone = phone || ""
	address = address || ""
	erb :new_contact
end

post '/new_contact' do
	first_name = params[:first_name]
	last_name = params[:last_name]
	phone = params[:phone]
	address = params[:address]

	conn.exec_prepared('cons', [params[:first_name] , params[:last_name], params[:phone], params[:address]])

	redirect '/phonebook'
end

get '/sessions/logout' do
	session.clear
	redirect '/'
end


