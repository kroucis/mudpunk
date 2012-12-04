#
# stackable.rb
# Copyright (c) 2012 Kyle Roucis. All rights reserved.
# Stackable
#
# The Stackable
require_relative 'named'

module Stackable
  include Named

  attr_accessor :count
  attr_accessor :limit

  def taken takes
    super
    takes.entities.each do |e|
      if e.name == self.name and e != self and e.kind_of? Stackable
        t = e.limit - e.count
        self.count -= t
        e.count += t
        e.remove_ent self if self.count <= 0
      end
    end
  end

end # Stackable
