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
end
