require 'sinatra'
require 'pg'
require 'securerandom'
require 'bcrypt'

load 'local_env.rb' if File.exist?('local_env.rb')

enable :sessions

conn = PG::Connection.open(:host => ENV['DB_HOST'], :user => ENV['DB_USERNAME'], :dbname => ENV['DB_NAME'], :port => ENV['DB_PORT'], :password => ENV['DB_PASSWORD'])

def prepare_statements(conn)
	conn.prepare("ndb", "insert into user_info (uuid, user_id, user_pass) values($1, $2, $3)")
	conn.prepare("cons", "insert into contacts (names, phone, address, owner) values($1, $2, $3, $4)")
end
prepare_statements(conn)


get '/' do
	erb :login
end

post '/new_user' do
	username = params[:username]
	password = params[:password]
	password2 = params[:password2]
	my_password = BCrypt::Password.create(password)

	if password != password2
		redirect '/'
	end

	conn.exec_prepared('ndb', [SecureRandom.uuid, params[:username], my_password])

	res = conn.exec("SELECT * FROM user_info WHERE user_id = '#{username}' AND user_pass = '#{my_password}'")

	res.each do |n|
		session[:table_id] = n['uuid']
		session[:user_name] = n['user_id']
		redirect '/phonebook'
	end
end

post '/existing_user' do
	username = params[:username]
	password = params[:password]

	res = conn.exec("SELECT * FROM user_info WHERE user_id = '#{username}' ")

	res.each do |n|
		session[:table_id] = n['uuid']
		session[:user_name] = n['user_id']
		redirect '/phonebook'
	end
end

get '/new_contact' do
	names = names || ""
	phone = phone || ""
	address = address || ""
	owner = owner || ""

	erb :new_contact
end

post '/new_contact' do
	names = params[:names]
	phone = params[:phone]
	address = params[:address]
	owner = session[:table_id]
	
	conn.exec_prepared('cons', [params[:names], params[:phone], params[:address], session[:table_id]])
	redirect '/phonebook'
end

get '/phonebook' do
	names = names || ""
	phone = phone || ""
	address = address || ""
	owner = owner || ""
	
	res = conn.exec("SELECT * FROM contacts WHERE owner = '#{session[:table_id]}' ")
	p res[1]
	res_arr = []
	res.each do |r|
		res_arr << r
	end
	p res_arr[1]
	erb :phonebook, locals:{res_arr: res_arr}
end

post '/delete_con' do
	owner = session[:table_id]
	id = params[:row]
	# p "from the delete_con the row is #{res2} and params are #{params[:id]}"

	res = conn.exec("SELECT * FROM contacts WHERE owner = '#{session[:table_id]}' ")
	# p "res2 returning id is #{res2}"
	row = []
	res.each do |r|
		row << r['id']
	end
	# row.each_with_index do |id|
	# 	row[id]
	# end
	p "row is #{row}"
	# p "params[:id] is #{params[:id]}"
	
	# res = conn.exec("SELECT * FROM contacts WHERE owner = '#{session[:table_id]}'")
	# p "res is #{res}"
	# res_id = []
	# res.each do |r|
	# 	res_id << r['id']
	# 	p "#res_id is '#{res_id}'"
	# end
		
	conn.exec("DELETE FROM contacts WHERE id = #{row}")

	redirect '/phonebook?'
end

get '/sessions/logout' do
	session[:table_id] = nil
	session[:user_name] = nil
	redirect '/'
end

