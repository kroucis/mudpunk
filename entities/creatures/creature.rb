#
# creature.rb
# Copyright (c) 2012 Kyle Roucis. All rights reserved.
# Creature < Entity + Sensing + Mobile
#

require_relative '../entity'
require_relative '../../behaviors/sensing'
require_relative '../../behaviors/mobile'
require_relative '../../behaviors/healthy'
require_relative '../../behaviors/reactive'
require_relative 'player'

module MUD
  module Entities
    class Creature < Entity
      include Behaviors::Sensing
      include Behaviors::Mobile
      include Behaviors::Healthy
      include Behaviors::Reactive

      def initialize
        @sensing_states = [ ]
        @mobile_states = [ ]
        @injury = Behaviors::Healthy::HEALTHY
      end

      def from_h hash
        super
        self.conscious = hash[:conscious]
        self.sensing_states = hash[:sensing_states] || [ ]
        self.mobile_states = hash[:mobile_states] || [ ]
        self.injury = hash[:injury] || Behaviors::Healthy::HEALTHY
        @onEntityEntered = hash[:entity_entered]
        @onEntityExited = hash[:entity_exited]
        @onDeath = hash[:dead]
      end

      def to_h
        result = super
        result[:mobile_states] = self.mobile_states
        result[:sensing_states] = self.sensing_states
        result[:conscious] = self.conscious
        result[:injury] = self.injury || Behaviors::Healthy::HEALTHY
        result[:entity_entered] = @onEntityEntered if @onEntityEntered
        result[:entity_exited] = @onEntityExited if @onEntityExited
        result[:dead] = @onDeath if @onDeath
        result
      end

      def died
        mud = MUD.instance
        zone = nil
        room = nil
        if self.room
          room = self.room
          zone = room.zone
        end

        eval @onDeath if @onDeath
      end

      def entity_entered_room entity, room
        if @onEntityEntered
          mud = MUD.instance
          zone = room.zone

          eval @onEntityEntered
        end
      end

      def entity_exited_room entity, room
        if @onEntityExited
          mud = MUD.instance
          zone = room.zone

          eval @onEntityExited
        end
      end

      protected
      def corpsify
        self.room.show "#{self.name} died."
        corpse = Entity.new
        corpse.name = "A dead #{self.name}"
        z = self.zone
        r = self.room
        r.remove_entity self, true
        r.add_entity corpse, true
        corpse.zone = z
      end

    end # Creature

  end

end
