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
	begin
	rescue
		redirect '/'
	end
	erb :login
end

post '/new_user' do
	username = params[:username]
	password = params[:password]
	password2 = params[:password2]
	my_password = BCrypt::Password.create(password)
	begin
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
	rescue
		redirect '/'
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

get '/phonebook' do
	names = names || ""
	phone = phone || ""
	address = address || ""
	owner = owner || ""
	id = session[:id]

	res = conn.exec("SELECT * FROM contacts WHERE owner = '#{session[:table_id]}' ")
	res_arr = []
	res.each do |r|
		res_arr << r
	end

	erb :phonebook, locals:{res_arr: res_arr}
end

# post '/phonebook' do
# 	names = params[:names2]
# 	phone = params[:phone2]
# 	address = params[:address2]
# 	owner = session[:id]

	
# # UPDATE contacts
# #     SET { names = {  | DEFAULT } |
# #           ( column_name [, ...] ) = [ ROW ] ( { expression | DEFAULT } [, ...] ) |
# #           ( column_name [, ...] ) = ( sub-SELECT )
# #         } [, ...]
# #     [ FROM from_list ]
# #     [ WHERE condition | WHERE CURRENT OF cursor_name ]
# #     [ RETURNING * | output_expression [ [ AS ] output_name ] [, ...] ]

# 	redirect '/phonebook'
# end

get '/new_contact' do
	names = names || ""
	phone = phone || ""
	address = address || ""
	owner = owner || ""
	id = session[:id]

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

get '/sessions/logout' do
	session[:table_id] = nil
	session[:user_name] = nil
	redirect '/'
end

post '/delete_con' do
	names = params[:names2]
	phone = params[:phone2]
	address = params[:address2]
	owner = session[:table_id]
	id = params[:id]
	p "id is #{id}"

	res = conn.exec("SELECT * FROM contacts WHERE owner = '#{session[:table_id]}'")

	
	conn.exec("DELETE FROM contacts WHERE id = '#{id}'")

	redirect '/phonebook'
end