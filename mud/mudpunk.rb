#
# mudpunk.rb
# Copyright (c) 2012 Kyle Roucis. All rights reserved.
# Connection
# rubygems, eventmachine
#

require 'rubygems'
require 'eventmachine'
require 'yaml'
require 'socket'

require_relative 'mud'
require_relative 'settings'
require_relative 'handlers'
require_relative '../util/player_utils'
require_relative '../util/room_utils'

require_relative '../souls/mortalsoul'
require_relative '../souls/wizardsoul'
require_relative '../souls/devsoul'

require_relative '../data/mudpunk/items'
require_relative '../data/mudpunk/creatures'

def my_first_private_ipv4
  result = nil
  address = Socket.ip_address_list.detect{|intf| intf.ipv4_private?}
  result = address.ip_address if address
  result
end

def my_first_public_ipv4
  result = nil
  address = Socket.ip_address_list.detect{|intf| intf.ipv4? and !intf.ipv4_loopback? and !intf.ipv4_multicast? and !intf.ipv4_private?}
  result = address.ip_address if address
  result
end

verbose = false
host = my_first_public_ipv4() || my_first_private_ipv4()
port = 0
ARGV.each do |arg|
  if arg == '--verbose' or arg == '-v' then
    verbose = true
  else
    port = arg.to_i
  end
end

puts 'Verbose mode: ON' if verbose

def save_chrono_data chrono, verbose=false
  yamld_chrono = YAML.dump chrono.to_h
  puts "Saving chrono #{yamld_chrono} to mudpunk_data/chrono.yaml" if verbose
  File.open("mudpunk_data/chrono.yaml", "w+") do |f| f.write yamld_chrono end
end

def save_state game, verbose=false
  game.loaded_zones.each do |zone_name, zone|
  end
end

Dir.mkdir './mudpunk_data' if not Dir.exists? './mudpunk_data'
Dir.mkdir './mudpunk_data/player_data' if not Dir.exists? './mudpunk_data/player_data'
Dir.mkdir './mudpunk_data/room_data' if not Dir.exists? './mudpunk_data/room_data'
Dir.mkdir './mudpunk_data/security' if not Dir.exists? './mudpunk_data/security'

chrono_data = nil
if File.exists? './mudpunk_data/chrono.yaml'
  chrono_data = YAML.load_file './mudpunk_data/chrono.yaml'
  puts "Loaded chrono #{chrono_data}" if verbose
end

calendar_data = YAML.load_file './data/mudpunk/calendar.yaml'

chrono_back = MUD::MUD.instance.load_calendar calendar_data, chrono_data
if chrono_back
  save_chrono_data chrono_back, verbose
end

MUD::MUD.instance.load_zone MUD::Settings.instance.start_zone

puts MUD::MUD.instance.chrono_str

MUD::Behaviors::Skillful.set_skills YAML.load_file './data/mudpunk/skills.yaml'

module Connection
  attr_accessor :player

  def handler= handler
    @handler = handler
    @handler.prompt
  end

  def post_init
    self.handler = UserNameHandler.new self
  end

  def greet player
    msg = "\n" +
              "================================== MUDPunk ==================================\n".white.bold + 
              "------------------------- A steampunk text universe -------------------------\n".cyan.bold + 
              "++++            Created by and Copyright (c) 2012 Kyle Roucis.           ++++\n".cyan.bold +
              '||            ' + '-=+*+=-'.magenta.bold + '              ' + '-=+*+=-'.green.bold + '            ' + '-=+*+=-'.magenta.bold + "              ||\n" +
              "||              *^*                                     *^*                ||\n" +
              "                   ---  Welcome to MUDPunk, #{player.name}!  ---\n"
    player.know msg, false
  end

  def receive_data data
    @buffer ||= BufferedTokenizer.new("\r\n")
    @buffer.extract(data).each do |line|
      line = line.strip
      if line.length > 0
        @handler.handle_input line
      end
    end
  end

  def unbind
    if @player.room
      MUD::PlayerUtils.save_player @player
    end
  end

end # Connection

EM.run do
  port = 8888 if port == 0
  puts "Starting server #{host}@#{port}"
  EM.start_server host, port, Connection
  EM.add_shutdown_hook do 
    save_chrono_data MUD::MUD.instance.chrono, verbose
    save_state MUD::MUD.instance, verbose
  end
end
