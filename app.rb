require 'sinatra'
require 'mysql2'

load 'local_env.rb' if File.exist?('local_env.rb')

enable :sessions

client = Mysql2::Client.new(:host => ENV['DB_HOST'], :username => ENV['DB_USERNAME'], :database => ENV['DB_NAME'], :port => ENV['DB_PORT'], :password => ENV['DB_PASSWORD'])

get '/' do
	erb :login
end

get '/new_user' do
	username = params[:username]
	password = params[:password]
	password2 = params[:password2]
	puts params
	erb :phonebook, locals:{username: "", password: "", password2: ""}
end

# post '/new_user' do
# 	username =  params[:username]
# 	password = params[:password]
# 	password2 = params[:password2]
# 	redirect '/phone_book?&username=' + username + '&password=' + password + '&password2=' + password
# end


