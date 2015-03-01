#
# VirtualMachine
#

require_relative '../../../behaviors/mobile'

module DecisionTape

    Operation = Struct.new :opcode, :functor

    class VirtualMachine
        attr_accessor :room
        attr_accessor :entity
        attr_accessor :error_handler
        attr_reader   :pc

        def initialize owner, room, install=true
            @ops = { }
            @stack = [ ]
            @entity = owner
            @room = room
            @pc = 0

            self.install_standard_ops if install
        end

        def install_standard_ops
            self.add_op(:push) do |x| self.push x end
            self.add_op(:add) do
              self.ensure (@stack.count >= 2), "Stack underflow in :add"
              x = self.pop
              y = self.pop
              self.push x+y
            end
            self.add_op(:add!) do |x|
              self.ensure (@stack.count >= 1), "Stack underflow in :add!"
              y = self.pop
              self.push x+y
            end
            self.add_op(:sub) do
              self.ensure (@stack.count >= 2), "Stack underflow in :sub"
              x = self.pop
              y = self.pop
              self.push y-x
            end
            self.add_op(:sub!) do |x|
              self.ensure (@stack.count >= 1), "Stack underflow in :sub!"
              y = self.pop
              self.push y-x
            end
            self.add_op(:eql) do
              self.ensure (@stack.count >= 2), "Stack underflow in :eql"
              x = self.pop
              y = self.pop
              self.push x==y
            end
            self.add_op(:eql?) do |x|
              self.ensure (@stack.count >= 1), "Stack underflow in :eql?"
              y = self.pop
              self.push x==y
            end
            self.add_op(:print) do
              self.ensure (@stack.count >= 1), "Stack underflow in :print"
              x = self.pop
              puts x
            end
            self.add_op(:print!) do |x|
              puts x
            end
            self.add_op(:exit!) do |x|
              self.ensure (@entity.is_a? MUD::Behaviors::Mobile), "Entity is not Mobile, cannot :exit!"
              self.ensure (@entity.can_move?), "Entity is immobilized, cannot :exit!"
              new_room = nil
              @room.exits.each do |k,r|
                if k.downcase.to_sym == x
                  new_room = r
                  break
                end
              end
              self.ensure new_room, "Room #{x} cannot be found for :exit!"

              puts "MOVING TO ROOM #{new_room} at exit #{x}"

              @entity.move_to new_room
              @room = @entity.room
            end
            self.add_op(:exit) do
              self.ensure (@stack.count >= 1), "Stack underflow in :exit"
              self.ensure (@entity.is_a? MUD::Behaviors::Mobile), "Entity is not Mobile, cannot :exit!"
              self.ensure (@entity.can_move?), "Entity is immobilized, cannot :exit!"

              room = self.pop
              self.ensure room, "No room to pop for :exit"
              @entity.move_to room
              @room = @entity.room
            end
            self.add_op(:entity_count) do
              self.push @room.entities.count - 1
            end
            self.add_op(:entity_total) do
              self.push @room.entities.count
            end
            self.add_op(:jump) do
              self.ensure (@stack.count >= 1), "Stack underflow in :jump!"
              self.jump self.pop
            end
            self.add_op(:jump!) do |x|
              self.jump x
            end
            self.add_op(:jump_rel) do
              self.ensure (@stack.count >= 1), "Stack underflow in :jump_rel!"
              self.jump_rel self.pop
            end
            self.add_op(:jump_rel!) do |x|
              self.jump_rel x
            end
            self.add_op(:jump_true!) do |x|
              self.ensure (@stack.count >= 1), "Stack underflow in :jump_true!"
              if self.pop
                self.jump_rel x
              end
            end
            self.add_op(:jump_false!) do |x|
              self.ensure (@stack.count >= 1), "Stack underflow in :jump_false!"
              if not self.pop
                self.jump_rel x
              end
            end
        end

        def add_operation op
            @ops[op.opcode] = op
        end

        def add_op opcode, &block
            lambda = block.to_proc
            op = Operation.new opcode, lambda
            self.add_operation op
        end

        def remove_op opcode
            @ops.delete[opcode]
        end

        def run_op opcode, arg=nil
            op = @ops[opcode]
            op.functor.call(arg) if op
        end

        def push val
            @stack.push val
        end

        def pop
          @stack.pop(1)[0]
        end

        def pop_n n=1
            @stack.pop(n)
        end

        def print_stack
            puts @stack
        end

        def jump new_pc
          @pc = new_pc
        end

        def jump_rel offset
          @pc += offset
        end

        def inc_pc
          @pc += 1
        end

        def error! info
          if @error_handler
            @error_handler.call info
          else
            raise Exception.new info
          end
        end

        protected
        def ensure tf, info
          if not tf
            self.error! info
          end
        end

    end

end
