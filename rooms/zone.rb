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

  def [] key
    @rooms ||= { }
    @rooms[key]
  end

end # Zone
