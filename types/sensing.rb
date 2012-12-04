#
# sensing.rb
# Copyright (c) 2012 Kyle Roucis. All rights reserved.
# Sensing
#

module Sensing
  BLIND       =   :blind
  DEAF        =   :deaf
  ANOSMIC     =   :anosmic
  NUMB        =   :numb

  attr_reader :sensing_states

  def can_see?
    not @sensing_states.include? Sensing::BLIND
  end

  def can_hear?
    not @sensing_states.include? Sensing::DEAF
  end

  def can_smell?
    not @sensing_states.include? Sensing::ANOSMIC
  end

  def can_feel?
    not @sensing_states.include? Sensing::NUMB
  end

  def see ent, bright = false
  end

  def hear ent, loud = false
  end

  def smell ent, pungent = false
  end

  def feel ent, overwhelming = false
  end

  def sense ent
  end

  def blind!
    @sensing_states ||= [ ]
    @sensing_states << Sensing::BLIND
  end

  def deafen!
    @sensing_states ||= [ ]
    @sensing_states << Sensing::DEAF
  end

  def anosmiate!
    @sensing_states ||= [ ]
    @sensing_states << Sensing::ANOSMIC
  end

  def numb!
    @sensing_states ||= [ ]
    @sensing_states << Sensing::NUMB
  end

  def remove_sense_state ss
    @sensing_states.delete ss
  end

end # Sensing
