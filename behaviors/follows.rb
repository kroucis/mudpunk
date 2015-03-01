require_relative 'mobile'
require_relative 'reactive'

module MUD
  module Behaviors
    module Follows
      include Mobile
      include Reactive

      public
      attr_reader :target

      def target_changed_rooms ent, rm
        if @target and @target == ent
          self.move_to rm
        end
      end

    end

  end

end
