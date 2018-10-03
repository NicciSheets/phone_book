require 'sinatra'
require 'pg'
require 'securerandom'
require 'bcrypt'
require_relative 'db_functions.rb'

load 'local_env.rb' if File.exist?('local_env.rb')

enable :sessions

get '/' do
	message = message || ""
	error_msg = error_msg || ""
	erb :login, locals:{message: message, error_msg: error_msg}
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
	error_msg = ""
	p "params in new_user is '#{params[:username]}' and the uuid is '#{uuid}'"

	# if password != password2
	# 	error_msg << "Passwords do not match, please try again."
	# 	redirect '/error?error_msg=' + error_msg
	# 	# erb :login, locals:{error_msg: error_msg}
	# end

	message = create_user_db(uuid, username, my_password)
	
	if message == "Username Already Taken"
		error_msg << "Username already taken, please try again."
		erb :login, locals:{error_msg: error_msg}
	elsif password != password2
		error_msg << "Passwords do not match, please try again."
		erb :login, locals:{error_msg: error_msg}
	else
		redirect '/phonebook?uuid=' + uuid 
	end
end

post '/existing_user' do


end


get '/phonebook' do
	erb :phonebook
end