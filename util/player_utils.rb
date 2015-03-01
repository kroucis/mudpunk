require_relative '../entities/creatures/player'
require_relative 'security'

module MUD
  module PlayerUtils
    private
    PLAYER_DATA_PATH = 'mudpunk_data/player_data'
    PLAYER_PASSWORD_PATH = 'mudpunk_data/security'
    PLAYER_DATA_EXT = 'mudpunkplayer'
    PLAYER_PASSWORD_EXT = 'mudpunkpass'

    public
    def self.load_player name, password
      player = nil
      player_yaml = nil
      if Dir.exists? PLAYER_PASSWORD_PATH
        pass_path = "#{PLAYER_PASSWORD_PATH}/#{name}.#{PLAYER_PASSWORD_EXT}"
        if File.exists? pass_path
          h = YAML.load_file pass_path
          hashed_password = Security::HashedPassword.new h[:algorithm], h[:iterations].to_i, h[:salt], h[:hash]
          if Security.valid? password, hashed_password
            player_yaml = YAML.load_file "#{PLAYER_DATA_PATH}/#{name}.#{PLAYER_DATA_EXT}"
            player = Entities::Player.from_h player_yaml
          end
        end
      end

      if player_yaml
        { 
          player: player,
          zone_name: player_yaml[:zone_name],
          room_name: player_yaml[:room_name] 
        }
      else
        nil
      end
    end

    def self.secure_player name, password
      saved = false
      if name
        if password
          hashed_password = Security.password_hash password
          hashed = {
            algorithm:  hashed_password.algorithm,
            iterations: hashed_password.iterations,
            salt:     hashed_password.salt,
            hash:     hashed_password.hash
          }
          h = YAML.dump hashed
          File.open "#{PLAYER_PASSWORD_PATH}/#{name}.#{PLAYER_PASSWORD_EXT}", 'w+' do |file|
            file.write h
          end
          saved = true
        end
      end
      saved
    end

    def self.player_exists? name
      p = File.exists? "#{PLAYER_PASSWORD_PATH}/#{name}.#{PLAYER_PASSWORD_EXT}"
      d = File.exists? "#{PLAYER_DATA_PATH}/#{name}.#{PLAYER_DATA_EXT}"
      p and d
    end

    def self.save_player player
      player_yaml = player.to_h.to_yaml
      File.open "#{PLAYER_DATA_PATH}/#{player.name}.#{PLAYER_DATA_EXT}", 'w+' do |file|
        file.write player_yaml
      end
    end

  end

end
