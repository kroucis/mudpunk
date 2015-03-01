module MUD
  module Behaviors
    module Skillful
      Skill = Struct.new :name, :level, :progress

      attr_reader :skills

      def self.set_skills skills
        @@skills = skills
      end

      def self.skill_hash
        skills = { }
        @@skills.each do |skill|
          s = skill.to_sym
          skills[s] = Skill.new s, 1, 0
        end
        skills
      end

      def gain_skill which, amount
        levels_gained = 0
        skill = @skills[which]
        skill.progress += amount
        old_lvl = skill.level
        while skill.progress >= skill.level
            levels_gained += 1
            skill.progress -= skill.level
        end
        if levels_gained > 0
          self.skill_leveled which, old_lvl, old_lvl + levels_gained
        end
        levels_gained
      end

      def skill_leveled which, old_lvl, new_lvl
        @skills[which].level = new_lvl
      end

      def skill_level which
        @skills[which].level
      end

      def skill_progress which
        @skills[which].progress
      end

      def challenge which, threshold, xp=1
        passed = false
        if self.skill_level >= threshold
          passed = true
        end

        self.gain_skill which, xp

        passed
      end

    end

  end

end