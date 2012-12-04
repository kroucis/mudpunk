#
# describable.rb
# Copyright (c) 2012 Kyle Roucis. All rights reserved.
# Describable
#

module Describable
	attr_accessor :descriptions

	def add_desc key, desc
		@descriptions ||= { }
		@descriptions[key] = desc
	end

	def remove_desc key
		@descriptions.delete key
	end

	def visible?
		@descriptions[:see] != nil
	end

	def audible?
		@descriptions[:hear] != nil
	end

	def physical?
		@descriptions[:feel] != nil
	end

	def smellable?
		@descriptions[:smell] != nil
	end

	def palatable?
		@descriptions[:taste] != nil
	end

end # Describable
