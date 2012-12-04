#
# reactive.rb
# Copyright (c) 2012 Kyle Roucis. All rights reserved.
# Reactive
#

module Reactive
	def entered_room rm
    if @room_change_listeners
      @room_change_listeners.each do |rcl|
        rcl.target_changed_rooms self, rm
      end
    end
	end

	def exited_room rm
	end

	def entity_entered_room ent, rm
	end

	def entity_exited_room ent, rm
	end

  def add_room_change_listener reactive
    @room_change_listeners ||= [ ]
    @room_change_listeners << reactive
  end

  def target_changed_rooms ent, rm
  end

end # Reactive
