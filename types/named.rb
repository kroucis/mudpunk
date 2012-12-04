#
# named.rb
# Copyright (c) 2012 Kyle Roucis. All rights reserved.
# Named
#

module Named
	protected
	@@named = { }

	public
	attr_reader :name

	def self.get_named name
		@@named[name]
	end

	def name= name
		@name = name
		@@named[@name] = self
	end
	
end # Named
