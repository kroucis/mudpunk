#
# mortalsoul.rb
# Copyright (c) 2012 Kyle Roucis. All rights reserved.
# WizardSoul
#

module MUD
	module Souls
		class WizardSoul
			def attach ent
				reg = 'status'
				prc = Proc.new do |input, matches|
						stats = ent.statuses
						if stats.count > 0
							ent.know 'Status Effects:'
							stats.each do |s|
								ent.know "- #{s.to_s.capitalize}"
							end
						else
							ent.know "No Status Effects"
						end
						ent.prompt
					end
				ent.add_cmd reg, prc

				reg = /broadcast\s+([\s\S]+)/
				prc = Proc.new do |input, matches|
						match = matches.flatten()[0]
						MUD.instance.players.each do |n, p|
							p.know match.bg_cyan.clear
							p.prompt
						end
					end
				ent.add_cmd reg, prc, 'broadcast <message>'

				reg = /warn\s+([\s\S]+)/
				prc = Proc.new do |input, matches|
						match = matches.flatten()[0]
						MUD.instance.players.each do |n, p|
							p.know match.bg_red.clear
							p.prompt
						end
					end
				ent.add_cmd reg, prc, 'warn <message>'

				reg = 'uptime'
				prc = Proc.new do |input, matches|
						ent.know "Uptime: #{MUD.instance.uptime.to_s}s"
						ent.prompt
					end
				ent.add_cmd reg, prc

				reg = 'time'
				prc = Proc.new do |input, matches|
						ent.know Time.now.to_s
						ent.prompt
					end
				ent.add_cmd reg, prc

				reg = 'skills'
				prc = Proc.new do |input, matches|
						ent.know "Skills"
						ent.know "------------"
						ent.skills.each do |key, skill|
							ent.know "#{key.to_s.capitalize} -> lvl #{skill.level} | xp #{skill.progress}"
						end
						ent.prompt
					end
				ent.add_cmd reg, prc
			end # attach

			def detach ent
				ent.remove_cmd('status')
				ent.remove_cmd(/broadcast ([\s\S]+)/)
			end # detach

		end # WizardSoul

	end

end
