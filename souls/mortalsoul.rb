#
# mortalsoul.rb
# Copyright (c) 2012 Kyle Roucis. All rights reserved.
# MortalSoul
#

require 'yaml'

require_relative '../behaviors/sensing'
require_relative '../behaviors/takeable'
require_relative '../behaviors/stackable'
require_relative '../util/player_utils'

module MUD
  module Souls

    ParsedTarget = Struct.new :container, :name, :index, :count, :item

    class MortalSoul
      INVENTORY_PREFIX  =   '^'
      ROOM_PREFIX       =   '-'
      EQUIP_PREFIX      =   '*'
      WORLD_PREFIX      =   '='
      INDEX_INFIX       =   '#'
      COUNT_INFIX       =   '*'

      def attach ent
        reg = 'cmdlist'
        prc = Proc.new do |input, matches|
          ent.know "Commands:"
          ent.command_list.each do |k|
            ent.know "- #{k.to_s}"
          end
          ent.prompt
        end # CMDLIST
        ent.add_cmd reg, prc

        reg = /(who|zvati)/
        prc = Proc.new do |input, matches|
          ent.know "Currently Connected Players:"
          MUD.instance.players.each do |n, p|
            ent.know "    #{ROOM_PREFIX} " + n
          end
          ent.prompt
        end # WHO
        ent.add_cmd reg, prc, "who (en) <> zvati tolojbotoi"

        reg = /(quit|cliva)/
        prc = Proc.new do |input, matches|
          ent.know "Goodbye #{ent.name}..."

          PlayerUtils.save_player ent

          ent.room.remove_entity ent
          MUD.instance.remove_player ent.name
          ent.connection.close_connection_after_writing
        end # QUIT
        ent.add_cmd reg, prc, "quit (en) <> cliva tolojbotoi"

        reg = /(inspect|details|regard|look|viska)\s+([\S]+)/
        prc = Proc.new do |input, matches|
          match = matches.flatten()[1]
          parsed = self.parse_target match, ent, ent.room, MUD.instance
          if parsed
            ent.sense parsed.item
          else
            ent.know "#{self.strip_target(match).capitalize} could not be found.".red
          end
          ent.prompt
        end # INSPECT
        ent.add_cmd reg, prc, "inspect|details|regard|look (en) <> viska tolojbotoi <entity> [#{ROOM_PREFIX}]"

        reg = /(look|viska)/
        prc = Proc.new do |input, matches|
          rm = ent.room
          ent.see "========== #{rm.name} =========="
          ent.sense rm
          if rm.entities and (rm.entities.count - 1) > 0
            ent.see "Entities:"
            rm.entities.each do |e|
              if e != ent
                ent.see "\t- #{e.name}"
              end
            end
          end
          if rm.exits and rm.exits.count > 0
            ent.see "Exits:"
            rm.exits.each do |exit, dest|
              if dest.is_a? RoomExit
                name = dest.room.name
              elsif dest.is_a? ZoneExit
                name = dest.room_name
              end
              ent.see "\t- #{exit} -> #{name}"  
            end
          end
          ent.prompt
        end # LOOK
        ent.add_cmd reg, prc, "look (en) | viska tolojbotoi"

        reg = /(go|walk|travel|run|move|klama)\s+([\S]+)/
        prc = Proc.new do |input, matches|
          if ent.can_move? and ent.can_see?
            match = matches.flatten()[1].downcase.to_sym
            moved = ent.move_to match
            if not moved
              ent.know "You cannot go that way."
              ent.prompt
            end
          elsif not ent.can_see?
            ent.know "You can't see enough to navigate!"
            ent.prompt
          else
            ent.know 'You cannot move!'
            ent.prompt
          end
          # don't need prompt, move_to will take care of that...
        end # GO
        ent.add_cmd reg, prc, 'go|walk|travel|run|move (en) <> klama tolojbotoi <exit>'

        reg = /say\s+([\s\S]+)/
        prc = Proc.new do |input, matches|
          ent.room.entities.each do |p|
            match = matches.flatten()[0]
            if p != ent
              p.hear "#{ent.name} says: '#{match}'" if p.kind_of? Behaviors::Sensing
            else
              if ent.can_hear?
                ent.hear "You said: '#{match}'"
              else
                ent.know "Your words are lost to silence."
              end
            end
          end
          ent.prompt
        end # SAY
        ent.add_cmd reg, prc, 'say <message>'

        reg = /yell\s+([\s\S]+)/
        prc = Proc.new do |input, matches|
          match = matches.flatten()[0]
          ent.room.entities.each do |p|
            if p != ent and p.kind_of? Behaviors::Sensing
              p.hear "#{ent.name} yells: '#{match}'", true
            elsif p.kind_of? Behaviors::Sensing
              if ent.can_hear?
                ent.hear "You yell: '#{match}'", true
              else
                ent.know "Your words are lost to silence."
              end
            end
          end

          ent.room.exits.each_value do |r|
            r.entities.each do |p|
              if p != ent and p.kind_of? Behaviors::Sensing
                if p.can_see?
                  p.hear "#{ent.name} yells (from #{ent.room.name}): '#{match}'"
                else
                  p.hear "#{ent.name} yells from afar: '#{match}'"
                end
              elsif p.kind_of? Behaviors::Sensing
                if ent.can_hear?
                  ent.hear "You yell: '#{match}'"
                else
                  ent.know "Your words are lost to silence."
                end
              end
            end
          end
          ent.prompt
        end # YELL
        ent.add_cmd reg, prc, 'yell <message>'

        reg = /(take|loot|grab|lift|carry|lebna)\s+([\s\S]+)/
        prc = Proc.new do |input, matches|
          match = matches.flatten()[1]
          if match
            parsed = self.parse_target ROOM_PREFIX + match, ent, ent.room, MUD.instance
            if parsed
              item = parsed.item
              container = parsed.container
              if item.kind_of? Behaviors::Takeable and not item.weight.nil? and not ent.carrying? item
                success = ent.add_entity item
                if success
                  container.remove_entity item, true
                  ent.know "#{item.name.capitalize} taken (#{ent.carried_weight}/#{ent.max_weight})"
                else
                  ent.know "You cannot carry that."
                end
              else
                ent.know "Impossible.".red
              end
            else
              ent.know "#{self.strip_target(match).capitalize} could not be found.".red
            end
          end
          ent.prompt
        end # TAKE
        ent.add_cmd reg, prc, "take|loot|grab|lift|carry (en) <> lebna tolojbotoi <item> [#{ROOM_PREFIX}] => [#{INVENTORY_PREFIX}]"

        reg = /(drop|leave|place|remove|falcru)\s+([\s\S]+)/
        prc = Proc.new do |input, matches|
          match = matches.flatten()[1]
          if match
            parsed = self.parse_target INVENTORY_PREFIX + match, ent, ent.room, MUD.instance
            if parsed
              item = parsed[:item]
              container = parsed[:container]
              if item.kind_of? Behaviors::Takeable and ent.carrying? item
                success = container.remove_entity item
                if success
                  ent.room.add_entity item, true
                  ent.know "#{item.name.capitalize} dropped."
                else
                  ent.know "You can't drop that."
                end
              else
                ent.know "Impossible.".red
              end
            else
              ent.know "You are not carrying that.".red
            end
          end
          ent.prompt
        end # DROP
        ent.add_cmd reg, prc, "drop|leave|place|remove (en) <> falcru tolojbotoi <item> [#{INVENTORY_PREFIX}] => [#{ROOM_PREFIX}]"

        reg = /(inv|inventory|bevri)/
        prc = Proc.new do |input, matches|
          if ent.inventory and ent.inventory.count > 0
            ent.know "You are carring:\t\t(#{ent.carried_weight}/#{ent.max_weight})"
            ent.inventory.each do |item|
              ent.know "\t#{INVENTORY_PREFIX} #{item.name}\t\t(#{item.weight})"
            end
          else
            ent.know "You aren't carring anything."
          end
          ent.prompt
        end # INV
        ent.add_cmd reg, prc, "inv|inventory (en) <> bevri tolojbotoi"
      end # attach

      def detach ent
        ent.remove_cmd "cmdlist"
        ent.remove_cmd "who"
        ent.remove_cmd "quit"
        ent.remove_cmd "look"
        ent.remove_cmd(/say ([\s\S]+)/)
        ent.remove_cmd(/yell ([\s\S]+)/)
        ent.remove_cmd(/(walk|go|travel|run|move)\s+([\S]+)/)
        ent.remove_cmd(/(take|loot|grab|lift|carry)\s+([\s\S]+)/)
        ent.remove_cmd(/(drop|leave|place|remove)\s+([\s\S]+)/)
        ent.remove_cmd(/(inv|inventory)/)
      end # detach

      def parse_target str, ent, rm, mud
        lookup = Hash.new { rm }
        lookup[INVENTORY_PREFIX] = ent
        lookup[ROOM_PREFIX] = rm
        lookup[EQUIP_PREFIX] = ent

        split_str = str.split("\"")
        
        regex = Regexp.new "(?<container>[\\#{INVENTORY_PREFIX}|\\#{ROOM_PREFIX}|\\#{EQUIP_PREFIX}])?(?<name>[\\w]+)(\\#{INDEX_INFIX}(?<index>[\\d]+))?(\\#{COUNT_INFIX}(?<count>[\\d]+))?", Regexp::IGNORECASE
        results = regex.match str

        ret = (results and ParsedTarget.new)
        if ret
          container = lookup[results[:container]]
          index = (results[:index].to_i or 0)
          if split_str.count > 1
            name = split_str[1]
          else
            name = results[:name]
          end
          count = results[:count]
          item = container.find name, index
          if item
            ret.container = container
            ret.name = name
            ret.index = index
            ret.count = count
            ret.item = item
          else
            ret = nil
          end
        end
        ret
      end # parse_target

      def strip_target str
        split_str = str.split("\"")
        if split_str.count > 1
          split_str[1]
        else
          regex = Regexp.new "[\\#{INVENTORY_PREFIX}|\\#{ROOM_PREFIX}|\\#{EQUIP_PREFIX}]?(?<name>[\\w]+)(\\#{INDEX_INFIX}([\\d]+))?", Regexp::IGNORECASE
          results = regex.match str
          results[:name]
        end
      end # strip_target

    end # MortalSoul

  end

end
