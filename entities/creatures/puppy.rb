require_relative 'creature'
require_relative '../../types/follows'

class Puppy < Creature
  include Follows

  def entity_entered_room ent, rm
    if ent != self and self.can_see? and not @target
      @target = ent
      @target.add_room_change_listener self
    end
  end

  def bark
    @room.echo "#{self.name} says: 'Bark bark! Woof!'", self
  end

  def target_changed_rooms ent, rm
    super
    self.bark
  end

end