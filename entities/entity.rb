#
# entity.rb
# Copyright (c) 2012 Kyle Roucis. All rights reserved.
# Entity + Named + Describable
#

require_relative '../types/named'
require_relative '../types/describable'

class Entity
	include Named
	include Describable

	attr_accessor :room

    def self.from_h itemdef
        instance = self.new
        itemdef.each do |key, value|
            instance.instance_variable_set("@#{key}", value)
        end
        instance
    end
end
