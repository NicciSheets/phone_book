require 'sinatra'
require 'pg'
require 'securerandom'
require 'bcrypt'
require_relative 'db_functions.rb'

load 'local_env.rb' if File.exist?('local_env.rb')

enable :sessions

get '/' do
	error_msg = error_msg || ""
	erb :login, locals:{error_msg: error_msg}
end

get '/error' do
	error_msg = error_msg || ""
	erb :login, locals:{error_msg: error_msg}
end

post '/error' do
	error_msg = error_msg || ""
	erb :login, locals:{error_msg: error_msg}
end

post '/new_user' do
	username = params[:username]
	password = params[:password]
	password2 = params[:password2]
	my_password = BCrypt::Password.create(password)
	uuid = SecureRandom.uuid
	
	p "params in new_user is '#{params[:username]}' and the uuid is '#{uuid}'"

	db_func = create_user_db(uuid, username, my_password)
	p "db_func is #{db_func}"
	
	error_msg = ""
	if db_func == "Username Already Taken"
		error_msg << "Username already taken, please try again."
		erb :login, locals:{error_msg: error_msg}
	elsif password != password2
		error_msg << "Passwords do not match, please try again."
		erb :login, locals:{error_msg: error_msg}
	else
		session[:owner] = uuid
		redirect '/phonebook' 
	end
end

post '/existing_user' do
	username = params[:username]
	password = params[:password]
	password_hash = BCrypt::Password.create(password)
   	p "password_hash is #{password_hash} and its class is #{password_hash.class}"
   	my_password =  BCrypt::Password.new(password_hash)
   	p "my_password is #{my_password}"


	error_msg = ""
	db_func = signin_existing_user_db(username, my_password)
	p "db_func is #{db_func}"
	# if db_func == "Correct Username" && my_password == password 
	# 	redirect '/phonebook'
	# elsif db_func == "Correct Username" && my_password != password
	# 	error_msg << "Incorrect Password"
	# 	erb :login, locals:{error_msg: error_msg}
	# elsif db_func == "Incorrect Username" && my_password == password
	# 	error_msg << "Incorrect Username"
	# 	erb :login, locals:{error_msg: error_msg}
	# elsif db_func == "Incorrect Username" && my_password != password
	# 	error_msg << "Incorrect Username and Password"
	# 	erb :login, locals:{error_msg: error_msg}
	# end
	if db_func == "Correct Username" 
		if my_password == password 
			redirect '/phonebook'
		else
			error_msg << "Incorrect Password"
		end
	else
		if my_password == password
			error_msg << "Incorrect Username"
			erb :login, locals:{error_msg: error_msg}
		else
			error_msg << "Incorrect Username and Password"
			erb :login, locals:{error_msg: error_msg}
		end
	end
end


get '/phonebook' do
	erb :phonebook
end