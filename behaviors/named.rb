#
# named.rb
# Copyright (c) 2012 Kyle Roucis. All rights reserved.
# Named
#

module MUD
  module Behaviors
    module Named
      public
      attr_reader :name

      def self.get_named name
        @@named ||= { }
        @@named[name]
      end

      def name= name
        @@named ||= { }
        @@named.delete @name
        @name = name
        @@named[@name] = self
      end
      
    end # Named
  
  end

end
