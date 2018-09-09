require 'sinatra'
require 'mysql2'

load 'local_env.rb' if File.exist?('local_env.rb')

enable :sessions

client = Mysql2::Client.new(:host => ENV['DB_HOST'], :username => ENV['DB_USERNAME'], :database => ENV['DB_NAME'], :port => ENV['DB_PORT'], :password => ENV['DB_PASSWORD'])

get '/' do
	username = username || ""
	password = password || ""
	password2 = password2 || ""
	erb :login, locals:{username: "", password: "", password2: ""}
end

post '/new_user' do
	username = params[:username]
	password = params[:password]
	password2 = params[:password2]
	puts params
	redirect '/phonebook?username=' + username + '&password=' + password + '&password2=' + password2
end

post '/existing_user' do
	username = params[:username]
	password = params[:password]
	puts params
	redirect '/phonebook?username=' + username + '&password=' + password
end

get '/phonebook' do
	erb :phonebook
end

# post '/phonebook' do
# end



# post '/phonebook' do
# end

