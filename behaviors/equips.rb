require_relative '../entities/items/item'

module MUD
  module Behaviors
    module Equips
      EquipmentSlot = Struct.new :name, :item

      attr_reader :equipment

      def self.set_slots slots
        @@slots = slots
      end

      def equip item, slot
        if item.kind_of? Entities::Item and not self.equipment[slot]
          self.equipment[slot] = EquipmentSlot.new slot, item
        else
          false
        end
      end

      def equipped? item
        found = false
        self.equipment.each do |slot, equip|
          found = equip.item = item
        end
        found
      end

      def slot_empty? slot
        self.equipment[slot] == nil
      end

    end

  end

end
