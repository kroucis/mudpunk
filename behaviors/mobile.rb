#
# mobile.rb
# Copyright (c) 2012 Kyle Roucis. All rights reserved.
# Mobile
#

module MUD
  module Behaviors
    module Mobile
      IMMOBILE  = :immobile

      public
      attr_accessor :mobile_states
      def can_move? dist=1
        not @mobile_states.include?(Mobile::IMMOBILE)
      end

      def move_to exit_key
        moved = false
        if self.can_move?
          exit = self.room.exits[exit_key]
          if exit
            room = nil
            if exit.kind_of? ZoneExit
              zone = MUD.instance.loaded_zones[exit.zone_name]
              if not zone
                zone = MUD.instance.load_zone exit.zone_name, true
              end
              self.zone = zone
              room = zone.rooms[exit.room_name]
            else
              room = exit.room
            end

            if room
              self.room.remove_entity self
              room.add_entity self
              moved = true  
            end
          end
        end

        moved
      end

      def immobilize!
        @mobile_states ||= [ ]
        @mobile_states << Mobile::IMMOBILE
      end

      def remove_mobile_state ms
        @mobile_states.delete ms
      end

    end # Mobile

  end

end
