require_relative 'creature'

module MUD
  module Entities
    class NPC < Creature
      def corpsify
        corpse = Entity.new
        corpse.name = "#{self.name}'s corpse"
        self.room.add_entity corpse
        corpse.zone = self.zone
        self.room.remove_entity self
      end
      
    end

  end

end