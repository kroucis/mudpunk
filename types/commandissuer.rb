#
# commandissuer.rb
# Copyright (c) 2012 Kyle Roucis. All rights reserved.
# CommandIssuer
#

module CommandIssuer
	attr_accessor :souls
	def add_soul soul
		@souls ||= { }
		@souls [soul.class.to_s] = soul
		soul.attach self
	end

	def remove_soul soul
		s = @souls[soul]
		if s
			@souls.delete soul
			s.detach self
		end
	end

	def add_cmd cmd, prc, name = cmd
		@commands ||= { }
		@commands[cmd] = { action: prc, name: name }
	end

	def remove_cmd cmd
		@commands.delete cmd
	end

	def command_list
		list = [ ]
		@commands.each_value do |v|
			list << v[:name]
		end
		list
	end

end # CommandIssuer
