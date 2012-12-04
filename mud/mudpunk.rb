#
# mudpunk.rb
# Copyright (c) 2012 Kyle Roucis. All rights reserved.
# Connection
# rubygems, eventmachine
#

require 'rubygems'
require 'eventmachine'

require_relative 'mud'
require_relative '../souls/mortalsoul'
require_relative '../souls/wizardsoul'
require_relative '../souls/devsoul'

require_relative '../entities/items/item'
require_relative '../entities/creatures/puppy'

verbose = false
host = "127.0.0.1"
port = 0
ARGV.each do |arg|
	if arg == '--verbose' or arg == '-v' then
		verbose = true
	else
		port = arg.to_i
	end
end

puts "Loading rooms...".cyan if verbose
rooms = eval(File.open('mud/mudrooms.rb').read)
rooms.each do |r|
	room = Room.from_h r
	MUD.instance.add_room room
end

puts "Linking rooms...".magenta if verbose
MUD.instance.rooms.each_value do |r|
	MUD.instance.link_room r
end

item = Item.new
item.weight = 0.02
item.name = 'tallet'
item.add_desc :see, "A tallet; a smooth, oblong crystal with a notch on one end indicating its worth as 1 tallet."
MUD.instance.rooms['Glade'].add_entity item

item = Item.new
item.weight = 0.04
item.name = 'tallet'
item.add_desc :see, "A tallet; a smooth, oblong crystal with two notches on one end indicating its worth as 2 tallet."
MUD.instance.rooms['Glade'].add_entity item

puppy = Puppy.new
puppy.name = 'Rascal'
puppy.add_desc :see, "A scrappy dachsund, with a brown nose and wagging tail."
puppy.add_desc :smell, "He smells faintly of dirt and feces."
MUD.instance.rooms['Hell'].add_entity puppy

module Connection
	def post_init
		send_data "\n\nBy what name are you to be addressed?\n"
		# @default_command = Proc.new { |d| send_data "#{@name}: #{d}\n" }
		# @player = nil
	end

	def receive_data data
		@buffer ||= BufferedTokenizer.new("\r\n")
		@buffer.extract(data).each do |line|
			if not @player
				@player = Player.new line, self
				@player.send "\n"
				@player.send "================================= MUDPunk =================================".white.bold
				@player.send "------------------------ A steampunk text universe ------------------------".cyan.bold
				@player.send "++++ Created by and Copyright (c) 2012 Kyle Roucis and Thomas Niemasik ++++".cyan.bold
				@player.send "||           " + '-=+*+=-'.magenta.bold + '              ' + '-=+*+=-'.green.bold + '            ' + '-=+*+=-'.magenta.bold + "             ||"
				@player.send "||                                                                       ||"
				@player.send "                  ---  Welcome to MUDPunk, #{@player.name}!  ---\n"
				@player.add_soul DevSoul.new
				@player.add_soul WizardSoul.new
				@player.add_soul MortalSoul.new

				# @player.add_cmd 'ti', Proc.new { EM::Timer.new(2) { @player.hear "Your cell phone rings." } }

				MUD.instance.add_player line, @player
				MUD.instance.rooms["Glade"].add_entity @player
				@player.room = MUD.instance.rooms["Glade"]
				MUD.instance.add_connection line, self
			else
				@player.handle_input line
			end
		end
	end

end # Connection

EM.run do
	port = 8888 if port == 0
	puts "Starting server #{host}@#{port}"
	EM.start_server host, port, Connection
end
