#
# mortalsoul.rb
# Copyright (c) 2012 Kyle Roucis. All rights reserved.
# MortalSoul
#

require_relative '../types/sensing'
require_relative '../types/takeable'
require_relative '../types/stackable'

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
      ent.send "Commands:"
      ent.command_list.each do |k|
        ent.send "- #{k.to_s}"
      end
    end # CMDLIST
    ent.add_cmd reg, prc

    reg = 'who'
    prc = Proc.new do |input, matches|
      ent.send "Currently Connected Players:"
      MUD.instance.players.each do |n, p|
        ent.send "    #{ROOM_PREFIX} " + n
      end
    end # WHO
    ent.add_cmd reg, prc

    reg = 'quit'
    prc = Proc.new do |input, matches|
      ent.send "Goodbye #{ent.name}..."
      ent.room.remove_entity ent
      MUD.instance.remove_player ent.name
      ent.connection.close_connection_after_writing
    end # QUIT
    ent.add_cmd reg, prc

    reg = /(inspect|details|regard|look)\s+([\S]+)/
    prc = Proc.new do |input, matches|
      match = matches.flatten()[1]
      parsed = self.parse_target match, ent, ent.room, MUD.instance
      if parsed
        ent.sense parsed.item
      else
        ent.send "#{self.strip_target(match).capitalize} could not be found.".red
      end
    end # INSPECT
    ent.add_cmd reg, prc, "inspect|details|regard|look <entity> [#{ROOM_PREFIX}]"

    reg = 'look'
    prc = Proc.new do |input, matches|
      ent.entered_room ent.room
    end # LOOK
    ent.add_cmd reg, prc

    reg = /(go|walk|travel|run|move)\s+([\S]+)/
    prc = Proc.new do |input, matches|
      if ent.can_move? and ent.can_see?
        match = matches.flatten()[1].downcase.to_sym
        new_room = nil
        ent.room.exits.each do |k,r|
          if k.downcase.to_sym == match
            new_room = r
            break
          end
        end
        if new_room
          ent.move_to(new_room)
        else
          ent.send 'You cannot go that way.'
        end
      elsif not ent.can_see?
        ent.send "You can't see enough to navigate!"
      else
        ent.send 'You cannot move!'
      end
    end # GO
    ent.add_cmd reg, prc, 'go|walk|travel|run|move <exit>'

    reg = /say\s+([\s\S]+)/
    prc = Proc.new do |input, matches|
      ent.room.entities.each do |p|
        match = matches.flatten()[0]
        if p != ent
          p.hear "#{ent.name} says: '#{match}'" if p.kind_of? Sensing
        else
          if ent.can_hear?
            ent.hear "You said: '#{match}'"
          else
            ent.send "Your words are lost to silence."
          end
        end
      end
    end # SAY
    ent.add_cmd reg, prc, 'say <message>'

    reg = /yell\s+([\s\S]+)/
    prc = Proc.new do |input, matches|
      match = matches.flatten()[0]
      ent.room.entities.each do |p|
        if p != ent and p.kind_of? Sensing
          p.hear "#{ent.name} yells: '#{match}'", true
        elsif p.kind_of? Sensing
          if ent.can_hear?
            ent.hear "You yell: '#{match}'", true
          else
            ent.send "Your words are lost to silence."
          end
        end
      end

      ent.room.exits.each_value do |r|
        r.entities.each do |p|
          if p != ent and p.kind_of? Sensing
            if p.can_see?
              p.hear "#{ent.name} yells (from #{ent.room.name}): '#{match}'"
            else
              p.hear "#{ent.name} yells from afar: '#{match}'"
            end
          elsif p.kind_of? Sensing
            if ent.can_hear?
              ent.hear "You yell: '#{match}'"
            else
              ent.send "Your words are lost to silence."
            end
          end
        end
      end
    end # YELL
    ent.add_cmd reg, prc, 'yell <message>'

    reg = /(take|loot|grab|lift|carry)\s+([\s\S]+)/
    prc = Proc.new do |input, matches|
      match = matches.flatten()[1]
      if match
        parsed = self.parse_target ROOM_PREFIX + match, ent, ent.room, MUD.instance
        if parsed
          item = parsed.item
          container = parsed.container
          if item.kind_of? Takeable and not ent.carrying? item
            success = ent.add_entity item
            if success
              container.remove_entity item, true
              ent.send "#{item.name.capitalize} taken (#{ent.carried_weight}/#{ent.max_weight})"
            else
              ent.send "You cannot carry that."
            end
          else
            ent.send "Impossible.".red
          end
        else
          ent.send "#{self.strip_target(match).capitalize} could not be found.".red
        end
      end
    end # TAKE
    ent.add_cmd reg, prc, "take|loot|grab|lift|carry <item> [#{ROOM_PREFIX}] => [#{INVENTORY_PREFIX}]"

    reg = /(drop|leave|place|remove)\s+([\s\S]+)/
    prc = Proc.new do |input, matches|
      match = matches.flatten()[1]
      if match
        parsed = self.parse_target INVENTORY_PREFIX + match, ent, ent.room, MUD.instance
        if parsed
          item = parsed[:item]
          container = parsed[:container]
          if item.kind_of? Takeable and ent.carrying? item
            success = container.remove_entity item
            if success
              ent.room.add_entity item, true
              ent.send "#{item.name.capitalize} dropped."
            else
              ent.send "You can't drop that."
            end
          else
            ent.send "Impossible.".red
          end
        else
          ent.send "You are not carrying that.".red
        end
      end
    end # DROP
    ent.add_cmd reg, prc, "drop|leave|place|remove <item> [#{INVENTORY_PREFIX}] => [#{ROOM_PREFIX}]"

    reg = /(inv|inventory)/
    prc = Proc.new do |input, matches|
      if ent.inventory and ent.inventory.count > 0
        ent.send "You are carring:\t\t(#{ent.carried_weight}/#{ent.max_weight})"
        ent.inventory.each do |item|
          ent.send "\t#{INVENTORY_PREFIX} #{item.name}\t\t(#{item.weight})"
        end
      else
        ent.send "You aren't carring anything."
      end
    end # INV
    ent.add_cmd reg, prc, "inv|inventory <item> [#{INVENTORY_PREFIX}]"
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

    regex = Regexp.new "(?<container>[\\#{INVENTORY_PREFIX}|\\#{ROOM_PREFIX}|\\#{EQUIP_PREFIX}])?(?<name>[\\w]+)(\\#{INDEX_INFIX}(?<index>[\\d]+))?(\\#{COUNT_INFIX}(?<count>[\\d]+))?", Regexp::IGNORECASE
    results = regex.match str

    ret = (results and ParsedTarget.new)
    if ret
      container = lookup[results[:container]]
      index = (results[:index].to_i or 0)
      name = results[:name]
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
    regex = Regexp.new "[\\#{INVENTORY_PREFIX}|\\#{ROOM_PREFIX}|\\#{EQUIP_PREFIX}]?(?<name>[\\w]+)(\\#{INDEX_INFIX}([\\d]+))?", Regexp::IGNORECASE
    results = regex.match str
    results[:name]
  end # strip_target

end # MortalSoul
