# 
# zone.rb
# Copyright (c) 2012 Kyle Roucis. All rights reserved.
# Zone + Named
# 

require_relative '../types/named'
require_relative 'room'

class Zone
  include Named

  def add_room rm
    @rooms ||= { }
    @rooms[rm.name] = rm
  end

  def remove_room rm
    @rooms.delete rm.name
    @rooms = nil if @rooms.count <= 0
  end

  def link_room rm
    new_exits = { }
    rm.exits.each do |exit|
      if not exit.zone
        room = @rooms[exit.exit]
        exit.room = room
      end
    end
  end

end # Zone
