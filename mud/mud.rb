#
# mud.rb
# Copyright (c) 2012 Kyle Roucis. All rights reserved.
# MUD + Singleton, String
# singleton
#

require 'singleton'

require_relative '../entities/creatures/player'
require_relative '../rooms/room'

class MUD
  include Singleton

  attr_accessor :players
  attr_accessor :rooms

  def initialize
    @players = { }
    @connections = { }
    @rooms = { }
    @start_time = Time.now
    puts @start_time.utc
  end

  def add_player name, player
    @players[name] = player
    self.broadcast "#{name} connected.", player
  end

  def broadcast msg, player = nil
    @players.each { |n,p| p.send msg if p != player }
  end

  def remove_player name
    @players.delete name
    self.broadcast "#{name} disconnected."
  end

  def add_connection name, conn
    @connections[name] = conn
  end

  def remove_connection name
    @connections.delete name
  end

  def uptime
    Time.now() - @start_time
  end

  def add_room rm
    @rooms[rm.name] = rm
  end

  def link_room rm
    new_exits = { }
    rm.exits.each do |e,key|
      room = @rooms[key]
      new_exits[e] = room
    end
    rm.exits = new_exits
  end

  def find_named name, rm = nil
    found = nil
    if rm
      found = rm.find_named name
    else
      found = Named.get_named(name)
    end
    found
  end

end # MUD

class String
  CLEAR     = "\e[0m"
  BOLD    = "\e[1m"

  @@cli_colors = 
  { 
    black:      "\e[30m",
    red:        "\e[31m",
    green:      "\e[32m",
    yellow:     "\e[33m",
    blue:       "\e[34m",
    magenta:    "\e[35m",
    cyan:       "\e[36m",
    white:      "\e[37m",
    bg_red:     "\033[41m",
    bg_green:   "\033[42m",
    bg_yellow:  "\033[43m",
    bg_blue:    "\033[44m",
    bg_magenta: "\033[45m",
    bg_cyan:    "\033[46m",
  }

  def method_missing(meth, *args, &block)
    color = @@cli_colors[meth.to_sym]
    if color
      c = color + self + (((not args[0]) and CLEAR) or '')
    else
      super.method_missing(meth, args, block)
    end
  end

  def bold
    BOLD + self
  end

  def clear
    self + CLEAR
  end

end # String
