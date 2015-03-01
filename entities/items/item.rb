#
# item.rb
# Copyright (c) 2012 Kyle Roucis. All rights reserved.
# Item + Takeable
#

require_relative '../entity'
require_relative '../../behaviors/takeable'

module MUD
  module Entities
    class Item < Entity
      include Behaviors::Takeable

      def from_h hash
        super
        self.weight = hash[:weight]
        @onTaken = hash[:taken]
        @onDropped = hash[:dropped]
      end

      def to_h
        result = super
        result[:weight] = self.weight
        result[:taken] = @onTaken if @onTaken
        result[:dropped] = @onDropped if @onDropped
        result
      end

      def taken taker
        if @onTaken
          mud = MUD.instance
          room = nil
          zone = nil
          if self.room
            room = self.room
            zone = room.zone
          end
          
          eval @onTaken
        end
      end

      def dropped dropper
        if @onDropped
          mud = MUD.instance
          zone = nil
          if self.room
            room = self.room
            zone = room.zone
          end

          eval @onDropped
        end
      end

    end # Item

  end

end
