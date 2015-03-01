#
# player.rb
# Copyright (c) 2012 Kyle Roucis. All rights reserved.
# Player < Creature + CommandIssuer + Takes + Reactive
#

require_relative '../../behaviors/commandissuer'
require_relative '../../behaviors/takeable'
require_relative '../../behaviors/reactive'
require_relative '../../behaviors/skillful'
require_relative '../../behaviors/equips'
require_relative '../items/item'
require_relative 'creature'
require_relative '../../rooms/room'

module MUD
  module Entities
    class Player < Creature
      include Behaviors::CommandIssuer
      include Behaviors::Takes
      include Behaviors::Reactive
      include Behaviors::Skillful
      include Behaviors::Equips

      CMD_LIMIT     =   100
      WEIGHT_LIMIT  =   5

      protected
      attr_reader :commands
      attr_reader :past_cmds

      public
      attr_accessor :connection
      attr_accessor :language

      def self.from_h hash
        instance = self.new hash[:name], nil
        # TODO: SKILLS
        instance.from_h hash
        if hash[:inventory]
          hash[:inventory].each do |item_def|
            item = Item.from_h item_def
            instance.add_entity item, true
          end
        end
        instance
      end

      # def from_h hash
      #   self.descriptions = hash[:descriptions]
      #   @mobile_states = hash[:mobile_states]
      #   @sensing_states = hash[:sensing_states]
      #   @room = hash[:room_name]
      # end

      def initialize name, conn
        super()
        self.name = name
        @connection = conn
        @dead = false
        @max_weight = WEIGHT_LIMIT

        @descriptions = Behaviors::Describable::SensoryInfo.new
        @descriptions.see = "#{@name} is an upstanding citizen of our fair city."

        @skills = Behaviors::Skillful.skill_hash
        @equipment = { }
      end

      def handle_input input
        @past_cmds ||= [ ]
        if input == 'g'
          self.handle_input @past_cmds.last
        else
          default = Proc.new { |d, cap| self.know "UNKNOWN COMMAND: #{d}".red.bold; self.prompt }
          cmd = default
          res = nil
          self.commands.each do |k,c|
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
            self.past_cmds << input
            self.past_cmds.shift if self.past_cmds.count > CMD_LIMIT
          end
        end
      end # handle_input

      def see stuff, bright = false
        if self.can_see?
          s = stuff.white
          s = s.bold if bright
          self.know s
        end
      end

      def hear stuff, loud = false
        if self.can_hear?
          s = stuff.cyan
          s = s.bold if loud
          self.know s
        end
      end

      def feel stuff, overwhelming = false
        if self.can_feel?
          s = stuff.yellow
          s = stuff.bold if overwhelming
          self.know s
        end
      end

      def smell stuff, pungent = false
        if self.can_smell?
          s = stuff.magenta
          s = s.bold if pungent
          self.know s
        end
      end

      def taste stuff
        self.smell stuff
      end

      def sense describable
        if describable != self and describable.kind_of? Behaviors::Describable
          describable.descriptions.each do |key, desc|
            desc = "  " + desc
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
            name = nil
            if dest.kind_of? RoomExit
              name = dest.room.name
            elsif dest.kind_of? ZoneExit
              name = dest.room_name
            end
            self.see "\t- #{exit} -> #{name}"  
          end
        end

        super

        self.prompt
      end # entered_room

      def know msg, wrap=true
        msg = msg.wrap if wrap
        self.send msg
      end

      def send stuff, newline=true
        self.connection.send_data stuff + (newline ? "\r\n" : "")
      end

      def prompt the_prompt='> '
        self.send the_prompt, false
      end

      def blind!
        super
        self.know "You have been blinded!".bg_red
      end

      def deafen!
        super
        self.know "You have been deafened!".bg_red
      end

      def anosmiate!
        super
        self.know "You have lost your sense of smell!".bg_red
      end

      def numb!
        super
        self.know "You don't feel anything!".bg_red
      end

      def immobilize!
        super
        self.know "You can't move!".bg_red
      end

      def statuses
        stats = [ ]

        if self.sensing_states
          self.sensing_states.each do |ss|
            stats << ss
          end
        end

        if self.mobile_states
          self.mobile_states.each do |ms|
            stats << ms
          end
        end

        stats
      end # statuses

      def inventory
        self.entities or [ ]
      end

      def to_h
        result = super
        inv = [ ]
        self.inventory.each do |i|
          inv << i.to_h
        end
        result[:inventory] = inv

        souls = [ ]
        self.souls.each do |key, soul|
          souls << key
        end
        result[:souls] = souls

        result[:skills] = self.skills
        result[:equipment] = self.equipment
        
        result
      end

    end # Player

  end

end
