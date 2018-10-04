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
	# username.gsub!(/[^a-z0-9_\.]/, '') 
	password = params[:password]
	# password.gsub!(/[^0-9A-Za-z]/, '') 
	password2 = params[:password2]
	# password2.gsub!(/[^0-9A-Za-z]/, '') 
	uuid = SecureRandom.uuid 
	p "uuid is #{uuid}"
	error_msg = ""
	my_password = ""
	if password == password2
		my_password << BCrypt::Password.create(password)
	else
		my_password = ""
	end
	p "my password is #{my_password}"

	db_func = create_user_db(uuid, username, my_password)
	p "db_func is #{db_func}"

	error_msg = ""
	if db_func == "Username Already Taken"
		error_msg << "Username already in use, please try again."
		erb :login, locals:{error_msg: error_msg}
	elsif db_func == "Passwords Don't Match"
		error_msg << "Passwords do not match, please try again."
		erb :login, locals:{error_msg: error_msg}
	else		
		redirect '/phonebook?uuid=' + uuid	
	end
end


# need to take the bcrypt off
post '/existing_user' do
	username = params[:username]
	password = params[:password]
	
   	p "my_password is #{my_password}"
   	owner = params[:uuid]
   	p "uuid is #{owner}"
	error_msg = ""
	db_func = signin_existing_user_db(username, password)
	p "db_func is #{db_func}"
	if db_func == "Correct Username" 
		if my_password == password 
			redirect '/phonebook&owner=' + owner
		else
			error_msg << "Incorrect Password"
		end
	else
		error_msg << "Incorrect Username and Password"
		erb :login, locals:{error_msg: error_msg}
	end
end

get '/phonebook' do
	names = names || ""
	phone = phone || ""
	address = address || ""
	owner = params[:uuid]
	id = session[:id]

	p "owner is #{owner} and the sessions are #{params[:uuid]}"

	phonebook_res = phonebook_table(owner)
	res_arr = []
	phonebook_res.each do |r|
		res_arr << r
	end

	erb :phonebook, locals:{res_arr: res_arr, id: id, owner: owner, names: names, phone: phone, address: address}
end