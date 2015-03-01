# 
# 
# 

require_relative 'conscious'

module MUD
  module Behaviors
    module Healthy
      include Conscious

      HEALTHY         =   0
      MINOR_INJURY    =   1
      INJURED         =   2
      MAJOR_INJURY    =   3
      NEAR_DEATH      =   4
      DEAD            =   5

      KNOCK_OUT_CHANCE =
      {
        MINOR_INJURY => 0.1,
        INJURED => 0.3,
        MAJOR_INJURY => 0.6,
        NEAR_DEATH => 0.8,
      }

      protected
      attr_writer :injury

      public 
      attr_reader :injury

      def take_damage dam
        self.injury = [self.injury + dam, DEAD].min
        if self.injury == DEAD
          self.died
        else
          self.injured dam
        end
      end

      def injured dam
        ko_chance = KNOCK_OUT_CHANCE[self.injury]
        kod = false
        if ko_chance && Random.rand < ko_chance
          self.knock_unconscious!
          kod = true
        end
        kod
      end

      def heal_damage dam
        self.injury = [self.injury - dam, HEALTHY].min
      end

      def alive?
        self.injury != DEAD
      end

      def injured?
        self.alive? and self.injury != HEALTHY
      end

      def dead?
        not self.alive?
      end

    end # Healthy

  end # Behaviors

end # MUD
