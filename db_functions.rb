require 'pg'
require 'securerandom'
require 'bcrypt'

load 'local_env.rb' if File.exist?('local_env.rb')



conn = PG::Connection.open(:host => ENV['DB_HOST'], :user => ENV['DB_USERNAME'], :dbname => ENV['DB_NAME'], :port => ENV['DB_PORT'], :password => ENV['DB_PASSWORD'])

conn.prepare("cons", "insert into contacts (names, phone, address, owner) values($1, $2, $3, $4)")


# checks new username against all usernames in db, if username is not already taken, it allows user to pass information to user_info database for username and password
def create_user_db(uuid, username, my_password)
	conn = PG::Connection.open(:host => ENV['DB_HOST'], :user => ENV['DB_USERNAME'], :dbname => ENV['DB_NAME'], :port => ENV['DB_PORT'], :password => ENV['DB_PASSWORD'])
	conn.prepare("ndb", "insert into user_info (uuid, user_id, user_pass) values($1, $2, $3)")
	message = ""
	res = conn.exec("SELECT * FROM user_info WHERE user_id = '#{username}'")
	if res.num_tuples.zero? == false
		message = "Username Already Taken"
	else
		if my_password == ""
			message = "Passwords Don't Match"
		else 
			message = "Valid Username"
			conn.exec_prepared('ndb', [uuid, params[:username], my_password])
		end
	end
	message
end


# supposed to check username for existing user against database and somehwo incorporate the password for existing user, also
# ******This is not working correctly, probably need to creata a User class and do stuff with that.
def signin_existing_user_db(username, my_password)
	conn = PG::Connection.open(:host => ENV['DB_HOST'], :user => ENV['DB_USERNAME'], :dbname => ENV['DB_NAME'], :port => ENV['DB_PORT'], :password => ENV['DB_PASSWORD'])
	res = conn.exec("SELECT user_id, user_pass FROM user_info WHERE user_id = '#{username}'")
	message = ""
	if res.num_tuples.zero? == true
		message = "Incorrect Username"
	else
		message = "Correct Username"
	end
	message
end

def phonebook_table()
	conn = PG::Connection.open(:host => ENV['DB_HOST'], :user => ENV['DB_USERNAME'], :dbname => ENV['DB_NAME'], :port => ENV['DB_PORT'], :password => ENV['DB_PASSWORD'])
	conn.exec("SELECT * FROM contacts WHERE owner = '#{session[:uuid]}' ")
end