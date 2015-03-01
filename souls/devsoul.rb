#
# devsoul.rb
# Copyright (c) 2012 Kyle Roucis. All rights reserved.
# DevSoul
#

module MUD
  module Souls
    class DevSoul
      def attach ent
        reg = '\\shutdown'
        prc = Proc.new do |input, matches|
          EM.stop
        end
        ent.add_cmd reg, prc

        reg = /\\eval\s+([\s\S]+)/
        prc = Proc.new do |input, matches|
          match = matches.flatten()[0]
          eval match
          ent.prompt
        end
        ent.add_cmd reg, prc, '\eval <ruby>'

        reg = /\\eye\s+([\S]+)/
        prc = Proc.new do |input, matches|
          name = matches.flatten()[0]
          if name
            e = MUD.instance.find_named(name)
            if e
              if e.kind_of? Behaviors::Sensing
                if e.can_see?
                  e.blind!
                else
                  e.remove_sense_state Behaviors::Sensing::BLIND
                  e.know 'Your sight is restored!'.bg_cyan
                end
              end
            end
          end
          ent.prompt
        end
        ent.add_cmd reg, prc

        reg = /\\ear\s+([\S]+)/
        prc = Proc.new do |input, matches|
          name = matches.flatten()[0]
          if name
            e = MUD.instance.find_named(name)
            if e
              if e.kind_of? Behaviors::Sensing
                if e.can_hear?
                  e.deafen!
                else
                  e.remove_sense_state Behaviors::Sensing::DEAF
                  e.know 'Your hearing is restored!'.bg_cyan
                end
              end
            end
          end
          ent.prompt
        end
        ent.add_cmd reg, prc

        reg = /\\legs\s+([\S]+)/
        prc = Proc.new do |input, matches|
          name = matches.flatten()[0]
          if name
            e = MUD.instance.find_named(name)
            if e
              if e.kind_of? Behaviors::Mobile
                if e.can_move?
                  e.immobilize!
                else
                  e.remove_mobile_state Behaviors::Mobile::IMMOBILE
                  e.know 'Your movement is restored!'.bg_cyan
                end
              end
            end
          end
          ent.prompt
        end
        ent.add_cmd reg, prc

        reg = /\\nose\s+([\S]+)/
        prc = Proc.new do |input, matches|
          name = matches.flatten()[0]
          if name
            e = MUD.instance.find_named(name)
            if e
              if e.kind_of? Behaviors::Sensing
                if e.can_smell?
                  e.anosmiate!
                else
                  e.remove_sense_state Behaviors::Sensing::ANOSMIC
                  e.know 'Your sense of smell is restored!'.bg_cyan
                end
              end
            end
          end
          ent.prompt
        end
        ent.add_cmd reg, prc

        reg = /\\soul\s+([\S]+)\s+([\S]+)/
        prc = Proc.new do |input, matches|
          name = matches.flatten()[0]
          if name
            e = MUD.instance.find_named(name)
            if e
              if e.kind_of? Behaviors::CommandIssuer
                soul = matches.flatten()[1]
                soul = Kernel.const_get("MUD::Souls::#{soul}")
                soul = soul.new
                e.add_soul soul
              end
            end
          end
          ent.prompt
        end
        ent.add_cmd reg, prc

        reg = /\\drain\s+([\S]+)\s+([\S]+)/
        prc = Proc.new do |input, matches|
          name = matches.flatten()[0]
          if name
            e = MUD.instance.find_named(name)
            if e
              if e.kind_of? Behaviors::CommandIssuer
                soul = matches.flatten()[1]
                e.remove_soul(soul)
              end
            end
          end
          ent.prompt
        end
        ent.add_cmd reg, prc

        reg = /\\souls\s+([\S]+)/
        prc = Proc.new do |input, matches|
          name = matches.flatten()[0]
          if name
            e = MUD.instance.find_named(name)
            if e
              if e.kind_of? Behaviors::CommandIssuer
                ent.know "Souls For #{name}:"
                e.souls.each do |k,s|
                  ent.know "- #{k}"
                end
              end
            end
          end
          ent.prompt
        end
        ent.add_cmd reg, prc

        reg = /\\chrono/
        prc = Proc.new do |input, matches|
          ent.know MUD.instance.chrono_str
          ent.prompt
        end
        ent.add_cmd reg, prc
      end # attach

      def detach ent
        ent.remove_cmd(/\\shutdown/)
        ent.remove_cmd(/\\souls ([\s\S]+)/)
        ent.remove_cmd(/\\drain ([\s\S]+) ([\s\S]+)/)
        ent.remove_cmd(/\\soul ([\s\S]+) ([\s\S]+)/)
        ent.remove_cmd(/\\legs ([\s\S]+)/)
        ent.remove_cmd(/\\ear ([\s\S]+)/)
        ent.remove_cmd(/\\eye ([\s\S]+)/)
        ent.remove_cmd(/\\eval ([\s\S]+)/)
      end # detach

    end # DevSoul

  end # Souls

end # MUD