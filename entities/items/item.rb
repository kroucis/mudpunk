#
# item.rb
# Copyright (c) 2012 Kyle Roucis. All rights reserved.
# Item + Takeable
#

require_relative '../entity'
require_relative '../../types/takeable'

class Item < Entity
	include Takeable
end
