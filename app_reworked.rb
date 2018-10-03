require 'sinatra'
require 'pg'
require 'securerandom'
require 'bcrypt'
require_relative 'db_functions.rb'

load 'local_env.rb' if File.exist?('local_env.rb')

enable :sessions

get '/' do
	message = message || ""

	erb :login, locals:{message: message}
end

post '/new_user' do
	username = params[:username]
	password = params[:password]
	my_password = BCrypt::Password.create(password)
	uuid = SecureRandom.uuid
	p "params in new_user is '#{params[:username]}' and the uuid is '#{uuid}'"

	message = create_user_db(uuid, username, my_password)
	
	if message == "Username Already Taken"
		message
		redirect '/?message=' + message
	else
		redirect '/phonebook?uuid=' + uuid 
	end
end

get '/phonebook' do
	erb :phonebook
end