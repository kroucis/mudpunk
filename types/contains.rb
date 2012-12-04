#
# contains.rb
# Copyright (c) 2012 Kyle Roucis. All rights reserved.
# Contains, Carries + Contains
#

module Contains
  attr_reader   :entities

  def add_entity ent, quiet = false
    @entities ||= [ ]
    @entities << ent
  end

  def remove_entity ent, quiet = false
    removed = @entities.delete ent
    @entities = nil if @entities.count <= 0
    removed
  end

  def contains? ent
    (@entities and @entities.include? ent)
  end

  def find name, idx = 0
    items = (@entities and @entities.select { |i| i.name == name })
    (items and items[idx])
  end

end

module Carries
  include Contains

  attr_reader   :carried_weight
  attr_accessor :max_weight

  def add_entity ent, quiet = false
    @carried_weight ||= 0
    if ent.weight + @carried_weight > @max_weight
      return false
    end

    super
    @carried_weight += ent.weight
    true
  end

  def remove_entity ent, quiet = false
    removed = super
    if removed
      @carried_weight -= ent.weight
    end
    removed
  end

  def carrying? ent
    self.contains? ent
  end

end
