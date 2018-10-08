require 'pg'
require 'securerandom'
require 'bcrypt'

load 'local_env.rb' if File.exist?('local_env.rb')


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
def signin_existing_user_db(username, my_password)
	conn = PG::Connection.open(:host => ENV['DB_HOST'], :user => ENV['DB_USERNAME'], :dbname => ENV['DB_NAME'], :port => ENV['DB_PORT'], :password => ENV['DB_PASSWORD'])
	res = conn.exec("SELECT * FROM user_info WHERE user_id = '#{username}'")
	# p "res.values is #{res.values}"
	message = ""
	# p "res.values are #{res.values}"
	if res.num_tuples.zero? == false 
		password = res.values[0][2] 
		compare_password = BCrypt::Password.new(password)
		# p "#{password} is the password from database and #{compare_password} is how you get the passwords to match - by passing in the hash"
		# p "#{my_password} is my password from params"
		if compare_password == my_password
			message = "Correct Username and Password"
			# uuid = res.values[0][0]
		else compare_password != my_password
			message = "Correct Username and Incorrect Password"
		end
	else
		message = "Incorrect Username"
	end
	message
end

def get_uuid(username, my_password)
	conn = PG::Connection.open(:host => ENV['DB_HOST'], :user => ENV['DB_USERNAME'], :dbname => ENV['DB_NAME'], :port => ENV['DB_PORT'], :password => ENV['DB_PASSWORD'])
	res = conn.exec("SELECT * FROM user_info WHERE user_id = '#{username}'")
	uuid = res.values[0][0]
end


# allows user to see the phonebook database displayed as a table in html
def phonebook_table(owner)
	conn = PG::Connection.open(:host => ENV['DB_HOST'], :user => ENV['DB_USERNAME'], :dbname => ENV['DB_NAME'], :port => ENV['DB_PORT'], :password => ENV['DB_PASSWORD'])
	res = conn.exec("SELECT * FROM contacts WHERE owner = '#{session[:table_id]}'")
	res_arr = []
	res.each do |r|
		res_arr << r
	end
	res_arr 
end


# adds contact name, phone number and address to the correct owner db
def create_contact(names, phone, address, owner)
	conn = PG::Connection.open(:host => ENV['DB_HOST'], :user => ENV['DB_USERNAME'], :dbname => ENV['DB_NAME'], :port => ENV['DB_PORT'], :password => ENV['DB_PASSWORD'])
	conn.prepare("cons", "insert into contacts (names, phone, address, owner) values($1, $2, $3, $4)")
	res = conn.exec_prepared('cons', [params[:names], params[:phone], params[:address], session[:table_id]])
end


# deletes contact from table and db based on id
def delete_contact(id)
	conn = PG::Connection.open(:host => ENV['DB_HOST'], :user => ENV['DB_USERNAME'], :dbname => ENV['DB_NAME'], :port => ENV['DB_PORT'], :password => ENV['DB_PASSWORD'])
	res = conn.exec("SELECT id FROM contacts WHERE owner = '#{session[:table_id]}'")
	p "res values are #{res.values}"
	conn.exec("DELETE FROM contacts WHERE id = '#{params[:id]}'")
end