#
# secure_player.rb
#

require 'securerandom'
require 'base64'
require 'openssl'
require 'yaml'

module MUD
	module Security
		private
		ITERATIONS = 1000
		SALT_LENGTH = 24
		HASH_LENGTH = 24

		HASH_SECTIONS = 4

		public
		HashedPassword = Struct.new :algorithm, :iterations, :salt, :hash

		def self.password_hash password
			salt = SecureRandom.base64 SALT_LENGTH
			gen = OpenSSL::PKCS5::pbkdf2_hmac_sha1 password, salt, ITERATIONS, HASH_LENGTH
			return HashedPassword.new 'sha256', ITERATIONS, salt, Base64.encode64(gen)
		end

		def self.valid? password, hashed_password
			decoded = Base64.decode64 hashed_password.hash
			gen = OpenSSL::PKCS5::pbkdf2_hmac_sha1 password, hashed_password.salt, ITERATIONS, decoded.length
			decoded == gen
		end

	end

end
