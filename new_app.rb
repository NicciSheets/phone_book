require 'sinatra'
require 'pg'
require 'securerandom'
require 'bcrypt'

load 'local_env.rb' if File.exist?('local_env.rb')

enable :sessions

conn = PG::Connection.open(:host => ENV['DB_HOST'], :user => ENV['DB_USERNAME'], :dbname => ENV['DB_NAME'], :port => ENV['DB_PORT'], :password => ENV['DB_PASSWORD'])

def prepare_statements(conn)
	conn.prepare("ndb", "insert into user_info (uuid, user_id, user_pass) values($1, $2, $3)")
	conn.prepare("cons", "insert into contact_table (contact_name, contact_phone, contact_address, owner) values($1, $2, $3, $4)")
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
		# redirect '/phonebook'
		redirect '/new_login'
	end
end

post '/existing_user' do
	username = params[:username]
	password = params[:password]

	res = conn.exec("SELECT * FROM user_info WHERE user_id = '#{username}' ")

	res.each do |n|
		session[:table_id] = n['uuid']
		session[:user_name] = n['user_id']
		# redirect '/phonebook'
		redirect '/new_login'
	end
end

# get '/new_contact' do
# 	names = names || ""
# 	phone = phone || ""
# 	address = address || ""
# 	owner = owner || ""

# 	erb :new_contact
# end

# post '/new_contact' do
# 	names = params[:names]
# 	phone = params[:phone]
# 	address = params[:address]
# 	owner = session[:table_id]
	
# 	conn.exec_prepared('cons', [params[:names], params[:phone], params[:address], session[:table_id]])
# 	# redirect '/phonebook'
# 	redirect '/new_login'
# end

get '/new_login' do
	# names = names || ""
	# phone = phone || ""
	# address = address || ""
	# owner = owner || ""
	contact_name = contact_name || ""
	contact_phone = contact_phone || ""
	contact_address = contact_address || ""
	owner = owner || ""
	# res = conn.exec("SELECT * FROM contacts WHERE owner = '#{session[:table_id]}' ")
	# res_arr = []
	# res.each do |r|
	# 	res_arr << r
	# end
	# p "res_arr is #{res_arr}" 
	# erb :phonebook, locals:{res_arr: res_arr}
	erb :new_login
end

post '/new_login' do
	contact_name = params[:contact_name]
	contact_phone = params[:contact_phone]
	contact_address = params[:contact_address]
	owner = session[:table_id]
	conn.exec_prepared('cons', [params[:contact_name], params[:contact_phone], params[:contact_address], session[:table_id]])
	redirect 'new_login'
end