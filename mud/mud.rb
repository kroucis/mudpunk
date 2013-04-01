#
# mud.rb
# Copyright (c) 2012 Kyle Roucis. All rights reserved.
# MUD + Singleton, String
# singleton
#

require 'singleton'
require 'yaml'

require_relative '../entities/creatures/player'
require_relative '../rooms/room'
require_relative '../rooms/zone'

class MUD
  include Singleton

  attr_accessor :players
  attr_accessor :rooms
  attr_reader :loaded_zones

  def initialize
    @players = { }
    @connections = { }
    @start_time = Time.now
    @loaded_zones = { }
    puts @start_time.utc
  end

  def add_player name, player
    @players[name] = player
    self.broadcast "#{name} connected.", player
  end

  def broadcast msg, player = nil
    @players.each { |n,p| p.send msg if p != player }
  end

  def remove_player name
    @players.delete name
    self.broadcast "#{name} disconnected."
  end

  def add_connection name, conn
    @connections[name] = conn
  end

  def remove_connection name
    @connections.delete name
  end

  def uptime
    Time.now - @start_time
  end

  def load_zone zonename
    zone = @loaded_zones[zonename]
    if not zone
      zonedef = YAML.load_file("./data/zones/#{zonename}.yaml")
      zone = Zone.new
      zone.name = zonedef['name']
      zonedef['rooms'].each do |roomname, exit_dict|
        target_room = zone[roomname]
        if not target_room
          roomdef = YAML.load_file("./data/rooms/#{roomname}.yaml")
          target_room = Room.from_h roomdef
          target_room.exits = { }
          zone.add_room target_room
        end

        exit_dict.each do |exitname, exit_room|
          room = zone[exit_room]
          if not room
            roomdef = YAML.load_file("./data/rooms/#{exit_room}.yaml")
            room = Room.from_h roomdef
            room.exits = { }
            zone.add_room room
          end
          target_room.exits[exitname] = room
        end
      end
      @loaded_zones[zonename] = zone
    end
    zone
  end

  def find_named name, rm = nil
    found = nil
    if rm
      found = rm.find_named name
      if not found
        found = self.find_named name
      end
    else
      found = Named.get_named(name)
    end
    found
  end

end # MUD

class String
  CLEAR     = "\e[0m"
  BOLD    = "\e[1m"

  @@cli_colors = 
  { 
    black:      "\e[30m",
    red:        "\e[31m",
    green:      "\e[32m",
    yellow:     "\e[33m",
    blue:       "\e[34m",
    magenta:    "\e[35m",
    cyan:       "\e[36m",
    white:      "\e[37m",
    bg_red:     "\033[41m",
    bg_green:   "\033[42m",
    bg_yellow:  "\033[43m",
    bg_blue:    "\033[44m",
    bg_magenta: "\033[45m",
    bg_cyan:    "\033[46m",
  }

  def method_missing(meth, *args, &block)
    color = @@cli_colors[meth.to_sym]
    if color
      c = color + self + (((not args[0]) and CLEAR) or '')
    else
      super.method_missing(meth, args, block)
    end
  end

  def bold
    BOLD + self
  end

  def clear
    self + CLEAR
  end

end # String
