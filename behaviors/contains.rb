#
# contains.rb
# Copyright (c) 2012 Kyle Roucis. All rights reserved.
# Contains, Carries + Contains
#

module MUD
  module Behaviors
    module Contains
      protected
      def entities= ent
        @entities = ent
      end

      public
      attr_reader   :entities

      def add_entity ent, quiet = false
        self.entities ||= [ ]
        self.entities << ent
      end

      def remove_entity ent, quiet = false
        removed = self.entities.delete ent
        self.entities = nil if self.entities.count <= 0
        removed
      end

      def contains? ent
        (self.entities and self.entities.include? ent)
      end

      def find name, idx = 0
        items = (self.entities and self.entities.select { |i| i.name == name })
        (items and items[idx])
      end

    end # Contains

    module Carries
      include Contains

      protected
      def carried_weight= weight
        @carried_weight = weight
      end

      public
      attr_reader   :carried_weight
      attr_accessor :max_weight

      def add_entity ent, quiet = false
        return false if ent.weight.nil? or not ent.weight.is_a? Numeric

        self.carried_weight ||= 0
        if ent.weight + self.carried_weight > self.max_weight
          return false
        end

        super
        self.carried_weight += ent.weight
        true
      end

      def remove_entity ent, quiet = false
        removed = super
        if removed
          self.carried_weight -= ent.weight
        end
        removed
      end

      def carrying? ent
        self.contains? ent
      end

    end # Carries

  end

end
