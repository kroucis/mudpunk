#
# room.rb
# Copyright (c) 2012 Kyle Roucis. All rights reserved.
# Room + Named + Describable + Contains, Exit
#

require_relative '../types/reactive'
require_relative '../types/sensing'
require_relative '../types/named'
require_relative '../types/describable'
require_relative '../types/contains'

Exit = Struct.new :exit, :room, :zone

class Room
  include Named
  include Describable
  include Contains

  attr_accessor :exits

  def self.from_h rmdef
    r = Room.new rmdef[:name], rmdef[:descriptions]
    r.exits = rmdef[:exits]
    r
  end

  def initialize name = "NOWHERE", desc = { see: "An empty void..." }
    @entities = [ ]
    @exits = { }
    @name = name
    @descriptions = desc
  end

  def echo msg, origin = nil
    if @entities
      @entities.each do |ent|
        if ent.kind_of? Sensing
          ent.hear msg if not origin or origin != ent
        end
      end
    end
  end # echo

  def show msg, origin = nil
    if @entities
      @entities.each do |ent|
        if ent.kind_of? Sensing
          ent.see msg if not origin or origin != ent
        end
      end
    end
  end # show

  def add_entity ent, quiet = false
    self.show "#{ent.name} entered #{self.name}." if not quiet
    super
    ent.room = self
    if ent.kind_of? Reactive
      ent.entered_room self
    end
    if @entities
      @entities.each do |e|
        if e.kind_of? Reactive
          e.entity_entered_room ent, self
        end
      end
    end
  end # add_entity

  def remove_entity ent, quiet = false
    super
    ent.room = nil
    self.show "#{ent.name} left #{self.name}." if not quiet
    if ent.kind_of? Reactive
      ent.exited_room self
    end
    if @entities
      @entities.each do |e|
        if e.kind_of? Reactive
          e.entity_exited_room ent, self
        end
      end
    end
  end # remove_entity

end # Room
