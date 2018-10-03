require 'pg'
require 'securerandom'
require 'bcrypt'

load 'local_env.rb' if File.exist?('local_env.rb')

# checks new username against all usernames in db, if username is not already taken, it allows user to pass information to user_info database for username and password
def create_user_db(uuid, username, my_password)
	conn = PG::Connection.open(:host => ENV['DB_HOST'], :user => ENV['DB_USERNAME'], :dbname => ENV['DB_NAME'], :port => ENV['DB_PORT'], :password => ENV['DB_PASSWORD'])
	check = conn.exec("SELECT * FROM user_info WHERE user_id = '#{username}'")
	message = ""
	if check.num_tuples.zero? == false
		message = "Username Already Taken"
	else
		message = ""
		conn.exec("INSERT INTO user_info (uuid, user_id, user_pass) VALUES ('#{uuid}', '#{username}', '#{my_password}')")
	end
	message
end

def signin_existing_user_db(username, my_password)
	conn = PG::Connection.open(:host => ENV['DB_HOST'], :user => ENV['DB_USERNAME'], :dbname => ENV['DB_NAME'], :port => ENV['DB_PORT'], :password => ENV['DB_PASSWORD'])
		
end
