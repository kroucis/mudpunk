#
# creature.rb
# Copyright (c) 2012 Kyle Roucis. All rights reserved.
# Creature < Entity + Sensing + Mobile
#

require_relative '../entity'
require_relative '../../types/sensing'
require_relative '../../types/mobile'

class Creature < Entity
	include Sensing
	include Mobile

	CONSCIOUS 	= 	nil
	ASLEEP		=	:asleep
	BATTERED	=	:battered
	DYING		=	:dying

	attr_accessor :health
	attr_accessor :conscious

	def initialize
		@sensing_states = [ ]
		@mobile_states = [ ]
	end

	def knock_unconscious!
		@conscious = Creature::BATTERED
	end

	def conscious?
		@conscious == Creature::CONSCIOUS
	end

	def can_see?
		self.conscious? and super
	end

	def can_hear?
		self.conscious? and super
	end

	def can_smell?
		self.conscious? and super
	end

	def can_feel?
		self.conscious? and super
	end

end
