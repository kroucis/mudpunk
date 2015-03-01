#
# describable.rb
# Copyright (c) 2012 Kyle Roucis. All rights reserved.
# Describable
#

module MUD
  module Behaviors
    module Describable
      public
      class SensoryInfo
        public
        attr_accessor :see
        attr_accessor :hear
        attr_accessor :smell
        attr_accessor :feel
        attr_accessor :know

        def to_h
          {
            see: self.see,
            hear: self.hear,
            smell: self.smell,
            feel: self.feel,
            know: self.know,
          }
        end

        def from_h hash
          self.see = hash[:see]
          self.hear = hash[:hear]
          self.smell = hash[:smell]
          self.feel = hash[:feel]
          self.know = hash[:know]
        end

        def each
          yield :see, self.see if self.see
          yield :hear, self.hear if self.hear
          yield :smell, self.smell if self.smell
          yield :feel, self.feel if self.feel
          yield :know, self.know if self.know
        end

        def to_s
          super + self.to_h.to_s
        end

      end

      attr_accessor :descriptions

      def add_desc key, desc
        @descriptions ||= { }
        @descriptions[key] = desc
      end

      def remove_desc key
        @descriptions.delete key
      end

      def visible?
        @descriptions.see != nil
      end

      def audible?
        @descriptions.hear != nil
      end

      def physical?
        @descriptions.feel != nil
      end

      def smellable?
        @descriptions.smell != nil
      end

      def palatable?
        @descriptions.taste != nil
      end

    end # Describable

  end
  
end
