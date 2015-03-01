require 'singleton'
require 'yaml'

module MUD
    class Settings
        include Singleton

        protected
        attr_writer :start_zone
        attr_writer :start_room
        attr_writer :player_save_path
        attr_writer :zone_save_path

        public
        attr_reader :start_zone
        attr_reader :start_room
        attr_reader :player_save_path
        attr_reader :zone_save_path

        def initialize
            config = YAML.load_file './data/mudpunk/config.yaml'
            self.start_zone = config['start_zone']
            self.start_room = config['start_room']
            self.player_save_path = config['player_save_path']
            self.zone_save_path = config['zone_save_path']
        end

    end

end
