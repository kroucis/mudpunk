#
# mobile.rb
# Copyright (c) 2012 Kyle Roucis. All rights reserved.
# Mobile
#

module Mobile
	IMMOBILE	=	:immobile

	attr_accessor :mobile_states
	def can_move? dist = 1
		not @mobile_states.include?(Mobile::IMMOBILE)
	end

	def move_to(rm)
		if self.can_move?
			self.room.remove_entity self
			rm.add_entity self
		end
	end

	def immobilize!
		@mobile_states ||= [ ]
		@mobile_states << Mobile::IMMOBILE
	end

	def remove_mobile_state ms
		@mobile_states.delete ms
	end

end # Mobile
