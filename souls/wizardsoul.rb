#
# mortalsoul.rb
# Copyright (c) 2012 Kyle Roucis. All rights reserved.
# WizardSoul
#

class WizardSoul
	def attach ent
		reg = 'status'
		prc = Proc.new do |input, matches|
				stats = ent.statuses
				if stats.count > 0
					ent.send 'Status Effects:'
					stats.each do |s|
						ent.send "- #{s.to_s.capitalize}"
					end
				else
					ent.send "No Status Effects"
				end
			end
		ent.add_cmd reg, prc

		reg = /broadcast\s+([\S]+)/
		prc = Proc.new do |input, matches|
				match = matches.flatten()[0]
				MUD.instance.players.each do |n, p|
					p.send match.bg_cyan.clear
				end
			end
		ent.add_cmd reg, prc, 'broadcast <message>'

		reg = /warn\s+([\s\S]+)/
		prc = Proc.new do |input, matches|
				match = matches.flatten()[0]
				MUD.instance.players.each do |n, p|
					p.send match.bg_red.clear
				end
			end
		ent.add_cmd reg, prc, 'warn <message>'

		reg = 'uptime'
		prc = Proc.new do |input, matches|
				ent.send "Uptime: #{MUD.instance.uptime.to_s}s"
			end
		ent.add_cmd reg, prc

		reg = 'time'
		prc = Proc.new do |input, matches|
				ent.send Time.now.to_s
			end
		ent.add_cmd reg, prc
	end # attach

	def detach ent
		ent.remove_cmd('status')
		ent.remove_cmd(/broadcast ([\s\S]+)/)
	end # detach

end # WizardSoul
