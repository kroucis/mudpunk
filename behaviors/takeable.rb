#
# takeable.rb
# Copyright (c) 2012 Kyle Roucis. All rights reserved.
# Takeable, Takes + Carries
#

module MUD
  module Behaviors
    # The Takeable module interacts with the Takes module to track carried weight
    # and to trigger taken and dropped events.
    module Takeable
      public
    	attr_accessor :weight

    	def taken takes
    	end

    	def dropped takes
    	end

    end # Takeable

    require_relative 'contains'

    module Takes
      public
      include Carries

      def add_entity ent, quiet = false
        added = super
        if added 
          ent.taken self
        end
        added
      end

      def remove_entity ent, quiet = false
        removed = super
        if removed
          ent.dropped self
        end
        removed
      end

    end # Takes

  end

end
