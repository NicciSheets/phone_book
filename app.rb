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


# the error form gives information about what input may be incorrect and is not allowing the form to redirect to the phonebook page
get '/error' do
	error_msg = error_msg || ""
	erb :login, locals:{error_msg: error_msg}
end


# the error form gives information about what input may be incorrect and is not allowing the form to redirect to the phonebook page
post '/error' do
	error_msg = error_msg || ""
	erb :login, locals:{error_msg: error_msg}
end


# creates a new user in the user_info table if username is unique and all fields pass criteria for patterns
post '/new_user' do
	uuid = ""
	username = params[:username]
	password = params[:password]
	password2 = params[:password2]
	uuid << SecureRandom.uuid 
	session[:table_id] = uuid
	p "uuid is #{uuid} amd #{session[:table_id]}"
	
	my_password = ""
	if password == password2
		my_password << BCrypt::Password.create(password)
	else
		my_password = ""
	end
	# p "my password is #{my_password}"

	db_func = create_user_db(uuid, username, my_password)
	# p "db_func is #{db_func}"

	error_msg = ""
	if db_func == "Username Already Taken"
		error_msg << "Username already in use, please try again."
		erb :login, locals:{error_msg: error_msg}
	elsif db_func == "Passwords Don't Match"
		error_msg << "Passwords do not match, please try again."
		erb :login, locals:{error_msg: error_msg}
	else		
		redirect '/phonebook'	
	end
end


# sign in form for existing users, checks username and password against those already made in the db
post '/existing_user' do
	username = params[:username]
	my_password = params[:password]
	
	db_func = signin_existing_user_db(username, my_password)
	p "db_func is #{db_func}"

	error_msg = ""
	if db_func == "Correct Username and Incorrect Password"
		error_msg << "Password is incorrect, please try signing in again."
		erb :login, locals:{error_msg: error_msg}
	elsif db_func == "Incorrect Username"
		error_msg << "Username is incorrect, please try signing in again."
		erb :login, locals:{error_msg: error_msg}
	else db_func == "Correct Username and Password" 
		uuid = get_uuid(username, my_password)
		session[:table_id] = uuid
		p "uuid in existing user #{uuid} and sessions #{session[:table_id]}"
		redirect '/phonebook'
	end
end


# loads the phonebook main page, where users can add contacts, view their phonebook listings and signout
get '/phonebook' do
	names = names || ""
	phone = phone || ""
	address = address || ""
	owner = session[:table_id]
	id = id || ""
	# p "owner is #{owner} and #{session[:table_id]}"
	# p "id session is #{session[:id]}"

	res_arr = phonebook_table(owner)
	# id = session[:id]

	erb :phonebook, locals:{res_arr: res_arr}
end


# brings up the new contact page where users can enter contact information to be stored to db
get '/new_contact' do
	names = names || ""
	phone = phone || ""
	address = address || ""
	owner = owner || ""

	erb :new_contact
end


# allows you to submit the new contact information to db
post '/new_contact' do
	names = params[:names]
	phone = params[:phone]
	address = params[:address]
	owner = session[:table_id]
	
	create_contact(names, phone, address, owner)

	redirect '/phonebook'
end


post '/delete_con' do
	id = params[:id]
	p "id is #{id} and sessions are #{params[:id]}"
	delete_contact(id)

	redirect '/phonebook'
end

post '/update_con' do
	redirect '/phonebook'
end

get '/sessions/logout' do
	session[:table_id] = nil

	redirect '/'
end