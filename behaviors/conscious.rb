#
#
#

module MUD
  module Behaviors
    module Conscious
      CONSCIOUS   =   nil
      ASLEEP      =   :asleep
      BATTERED    =   :battered
      UNCONSCIOUS =   :unconscious

      public
      attr_accessor :conscious

      def knock_unconscious!
        @conscious = BATTERED
      end

      def conscious?
        @conscious == CONSCIOUS
      end

      def can_see?
        self.conscious? and super
      end

      def can_hear?
        self.conscious? and super
      end

      def can_smell?
        self.conscious? and super
      end

      def can_feel?
        self.conscious? and super
      end

    end

  end

end
