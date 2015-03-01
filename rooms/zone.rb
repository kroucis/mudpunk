# 
# zone.rb
# Copyright (c) 2012 Kyle Roucis. All rights reserved.
# Zone + Named
# 

require_relative '../behaviors/named'
require_relative 'room'

module MUD

  class Zone
    include Behaviors::Named

    protected 
    attr_writer :rooms

    public
    attr_reader :rooms
    attr_accessor :data

    def initialize
      @data = { }
    end

    def to_h
      rooms = { }
      self.rooms.each do |room_name, room|
        rooms[room_name.to_sym] = room.to_h
      end

      {
        name:   self.name,
        rooms:  rooms
      }
    end

    def add_room rm, name=nil
      name ||= rm.name
      self.rooms ||= { }
      self.rooms[name] = rm
    end

    def remove_room rm
      self.rooms.delete rm.name
      self.rooms = nil if self.rooms.count <= 0
    end

    def link_all_rooms verbose=false
      self.rooms.each do |e, room|
        puts "LINKING #{room.name}" if verbose
        room.zone = self
        new_exits = { }
        room.exits.each do |exit, room_name|
          split_exit = exit.split('|')
          ex = split_exit[0].to_sym
          if split_exit.count > 1
            new_exits[ex] = ZoneExit.new ex, split_exit[1], room_name
          else
            new_exits[ex] = RoomExit.new room_name, self[room_name]
            puts "  #{room_name}: #{ex} -> #{new_exits[ex]}" if verbose
          end
        end
        room.exits = new_exits
      end
    end

    def [] key
      self.rooms ||= { }
      self.rooms[key]
    end

  end # Zone

end
