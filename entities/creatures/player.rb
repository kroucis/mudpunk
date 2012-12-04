#
# player.rb
# Copyright (c) 2012 Kyle Roucis. All rights reserved.
# Player < Creature + CommandIssuer + Takes + Reactive
#

require_relative '../../types/commandissuer'
require_relative '../../types/takeable'
require_relative '../../types/reactive'
require_relative 'creature'

class Player < Creature
  include CommandIssuer
  include Takes
  include Reactive

  CMD_LIMIT     =   100
  WEIGHT_LIMIT  =   5

  attr_accessor :connection

  def initialize name, conn
    super()
    @name = name
    @connection = conn
    @dead = false
    @max_weight = WEIGHT_LIMIT

    @descriptions = { see: "#{@name} is an upstanding citizen of our fair city.", smell: "#{@name} reeks of onions!" }
  end

  def handle_input input
    @past_cmds ||= [ ]
    if input == 'g'
      self.handle_input @past_cmds.last
    else
      default = Proc.new { |d, cap| self.send "UNKNOWN COMMAND: #{d}".red.bold }
      cmd = default
      res = nil
      @commands.each do |k,c|
        if k.kind_of? String
          if input == k
            cmd = c[:action]
            break
          end
        else
          res = input.scan k
          if res.count > 0
            cmd = c[:action]
            break
          end
        end
      end
      cmd.call(input, res)

      if cmd != default
        @past_cmds << input
        @past_cmds.shift if @past_cmds.count > Player::CMD_LIMIT
      end
    end
  end # handle_input

  def see stuff, bright = false
    if self.can_see?
      s = stuff.white
      s = s.bold if bright
      self.send s
    end
  end

  def hear stuff, loud = false
    if self.can_hear?
      s = stuff.cyan
      s = s.bold if loud
      self.send s
    end
  end

  def feel stuff, overwhelming = false
    if self.can_feel?
      s = stuff.yellow
      s = stuff.bold if overwhelming
      self.send s
    end
  end

  def smell stuff, pungent = false
    if self.can_smell?
      s = stuff.magenta
      s = s.bold if pungent
      self.send s
    end
  end

  def taste stuff
    self.smell stuff
  end

  def sense describable
    if describable != self and describable.kind_of? Describable
      describable.descriptions.each do |key, desc|
        if block_given?
          desc = yield key, desc
        end
        self.public_send key, desc
      end
    end
  end # sense

  def entered_room rm
    self.see "========== #{rm.name} =========="
    self.sense rm
    if rm.entities and (rm.entities.count - 1) > 0
      self.see "Entities:"
      rm.entities.each do |e|
        if e != self
          self.see "\t- #{e.name}"
        end
      end
    end
    if rm.exits and rm.exits.count > 0
      self.see "Exits:"
      rm.exits.each do |exit, dest|
        self.see "\t- #{exit} -> #{dest.name}"  
      end
    end
    super
  end # entered_room

  def send stuff, newline = true
    @connection.send_data stuff + (newline ? "\r\n" : "")
  end

  def blind!
    super
    self.send "You have been blinded!".bg_red
  end

  def deafen!
    super
    self.send "You have been deafened!".bg_red
  end

  def anosmiate!
    super
    self.send "You have lost your sense of smell!".bg_red
  end

  def numb!
    super
    self.send "You don't feel anything!".bg_red
  end

  def immobilize!
    super
    self.send "You can't move!".bg_red
  end

  def statuses
    stats = [ ]

    if @sensing_states
      @sensing_states.each do |ss|
        stats << ss
      end
    end

    if @mobile_states
      @mobile_states.each do |ms|
        stats << ms
      end
    end

    stats
  end # statuses

  def inventory
    self.entities
  end

end # Player
