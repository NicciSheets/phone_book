require 'bcrypt'

def hash_password(password)
  BCrypt::Password.create(password).to_s
end

def test_password(password, user_hash)
  BCrypt::Password.new(user_hash) == password
end
