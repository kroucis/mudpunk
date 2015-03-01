#
# commandissuer.rb
# Copyright (c) 2012 Kyle Roucis. All rights reserved.
# CommandIssuer
#

module MUD
	module Behaviors
		module CommandIssuer
			protected
			attr_accessor :commands

			public
			attr_accessor :souls
			def add_soul soul
				self.souls ||= { }
				self.souls[soul.class.to_s] = soul
				soul.attach self
			end

			def remove_soul soul
				s = self.souls[soul]
				if s
					self.souls.delete soul
					s.detach self
				end
			end

			def add_cmd cmd, prc, name = cmd
				self.commands ||= { }
				self.commands[cmd] = { action: prc, name: name }
			end

			def remove_cmd cmd
				self.commands.delete cmd
			end

			def command_list
				list = [ ]
				self.commands.each_value do |v|
					list << v[:name]
				end
				list
			end

		end # CommandIssuer

	end

end
