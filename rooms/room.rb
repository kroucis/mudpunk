#
# room.rb
# Copyright (c) 2012 Kyle Roucis. All rights reserved.
# Room + Named + Describable + Contains, Exit
#

require_relative '../behaviors/reactive'
require_relative '../behaviors/sensing'
require_relative '../behaviors/named'
require_relative '../behaviors/describable'
require_relative '../behaviors/contains'

module MUD

  RoomExit = Struct.new :exit, :room
  ZoneExit = Struct.new :exit, :zone_name, :room_name

  class Room
    include Behaviors::Named
    include Behaviors::Describable
    include Behaviors::Contains

    attr_accessor :exits
    attr_accessor :zone
    attr_accessor :filename

    def self.from_h rmdef
      descs = { }
      rmdef[:descriptions].each do |sense, desc_ary|
        str = ""
        counter = 0
        desc_ary.each do |desc_str|
          if not desc_str or not desc_str.empty?
            if counter % 2 == 0
              if counter == 0
                str += desc_str
              else
                str += " " + desc_str
              end
            else
              str += " " + desc_str.bold.clear
            end
          end
          counter += 1
        end
        descs[sense.to_sym] = str
      end

      senseinfo = Behaviors::Describable::SensoryInfo.new
      senseinfo.from_h descs

      room = Room.new rmdef[:name], senseinfo

      if rmdef[:entities]
        rmdef[:entities].each do |ent_name|
          ent = Entities::Entity.build_entity ent_name
          room.add_entity ent
        end
      end

      room.filename = rmdef[:filename]

      room
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
          if ent.kind_of? Behaviors::Sensing
            ent.hear msg if not origin or origin != ent
          end
        end
      end
    end # echo

    def show msg, origin = nil
      if @entities
        @entities.each do |ent|
          if ent.kind_of? Behaviors::Sensing
            ent.see msg if not origin or origin != ent
          end
        end
      end
    end # show

    def add_entity ent, quiet = false
      self.show "#{ent.name} entered #{self.name}." if not quiet
      super
      ent.room = self
      if ent.kind_of? Behaviors::Reactive
        ent.entered_room self
      end
      if @entities
        @entities.each do |e|
          if e.is_a? Behaviors::Reactive
            e.entity_entered_room ent, self
          end
        end
      end
    end # add_entity

    def remove_entity ent, quiet = false
      super
      ent.room = nil
      self.show "#{ent.name} left #{self.name}." if not quiet
      if ent.kind_of? Behaviors::Reactive
        ent.exited_room self
      end
      if @entities
        @entities.each do |e|
          if e.kind_of? Behaviors::Reactive
            e.entity_exited_room ent, self
          end
        end
      end
    end # remove_entity

    def to_h
      hash = { }
      hash[:name] = self.name
      hash[:descriptions] = { }
      @descriptions.each do |sense, desc|
        puts desc
        hash[:descriptions][sense.to_sym] = desc
      end
      entities = [ ]
      if @entities
        @entities.each do |ent|
          entities << ent.to_h
        end
        hash[:entities] = entities
      end
      if @filename
        hash[:filename] = @filename
      end
      hash
    end

  end # Room

end
