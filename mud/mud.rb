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
require_relative '../util/string_extensions'
require_relative '../util/hash_extensions'
require_relative 'calendar'

module MUD
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

    def load_calendar calendar_yaml, chrono_yaml
      @calendar = Calendar.new calendar_yaml
      if not chrono_yaml
        year = (922..968).to_a.sample
        month_idx = (0..@calendar.months.length - 1).to_a.sample
        month = @calendar.months[month_idx]
        day = (1..month.days).to_a.sample
        hour = (0..21).to_a.sample
        minute = (0..59).to_a.sample
        second = (0..59).to_a.sample
        @chrono = Chrono.new year, month_idx, day, hour, minute, second, Time.now
      else
        @chrono = Chrono.from_h chrono_yaml
      end
    end

    def chrono
      diff = Time.now - @chrono.real_time
      diff = diff.to_i
      if diff >= 1
        seconds = diff % 60
        minutes = (diff / 60) % 60
        hours = (diff / 3600) % 22
        days = diff / 79200

        puts "#{days}d#{hours}h#{minutes}m#{seconds}s"

        @chrono.second += seconds
        if @chrono.second >= 60
          @chrono.second -= 60
          minutes += 1
        end

        @chrono.minute += minutes
        if @chrono.minute >= 60
          @chrono.minute -= 60
          hours += 1
        end

        @chrono.hour += hours
        if @chrono.hour >= 22
          @chrono.hour -= 22
          days += 1
        end

        @chrono.day += days
        while @chrono.day > @calendar.months[@chrono.month].days
          @chrono.day -= @calendar.months[@chrono.month].days - 1
          @chrono.day += 1
          @chrono.month += 1

          if @chrono.month > @calendar.months.length
            @chrono.month -= @calendar.months.length - 1
            @chrono.month += 1
            @chrono.year += 1
          end
        end
        @chrono.real_time = Time.now
      end
      @chrono
    end

    def chrono_str
      chrono = self.chrono
      "#{chrono.hour}:#{chrono.minute}:#{chrono.second} on #{chrono.day} of the #{@calendar.months[chrono.month].name} in #{chrono.year}"
    end

    def add_player name, player
      @players[name] = player
      self.broadcast "#{name} connected.", player
    end

    def broadcast msg, player = nil
      @players.each { |n,p| p.know msg if p != player }
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

    def load_zone zonename, verbose=false
      puts "Loading Zone #{zonename}..." if verbose
      zone = @loaded_zones[zonename]
      if not zone
        puts "#{zonename} not loaded, reading from disk..." if verbose
        zonedef = YAML.load_file "./data/zones/#{zonename}.yaml"
        puts zonedef if verbose
        zone = Zone.new
        zone.name = zonedef['name']
        zonedef['rooms'].each do |roomname, exit_dict|
          puts "Building room '#{roomname}'..." if verbose
          target_room = zone[roomname]
          if not target_room
            target_room = self.build_room roomname, exit_dict
            zone.add_room target_room, roomname
          end
        end
        zone.link_all_rooms
        @loaded_zones[zonename] = zone
      end
      zone
    end

    def build_room roomname, exits
      roomdef = YAML.load_file("./data/rooms/#{roomname}.yaml")
      roomdef = roomdef.symbolize_keys
      room = Room.from_h roomdef
      room.exits = exits
      room
    end

    def get_zone name
      zone = @loaded_zones[name]
      if not zone
        zone = self.load_zone name
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
        found = Behaviors::Named.get_named(name)
      end
      found
    end

  end # MUD

end
