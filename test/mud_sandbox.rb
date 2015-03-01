require_relative '../util/ai/decision_tape/decision_vm'
require_relative '../util/ai/decision_tape/decision_tape'
require_relative '../mud/mud'

class TestCreature < MUD::Entities::Creature
end

room1 = MUD::Room.new "SOMEWHERE", "yes"
room2 = MUD::Room.new "Elsewhnere", "no"

room1.exits = { south: room2 }
room2.exits = { east: room1 }

creature = TestCreature.new

room1.add_entity creature

vm = DecisionTape::VirtualMachine.new creature, room1

tape = DecisionTape::TapeStrip.new vm
tape.add_op :push, 9
tape.add_op :push, 1
tape.add_op :add, nil

tape.add_op :exit!, :south
tape.add_op :exit!, :east

tape.add_op :sub!, 7

# tmp = Proc.new do
#   x = vm.pop
#   y = vm.pop
#   vm.push x==y
# end

# vm.add_operation DecisionTape::Operation.new :eql, tmp

tape.add_op :eql?, 3
# tape.add_op :print, nil
tape.add_op :jump_false!, 2
tape.add_op :print!, "TRUE!"
tape.add_op :jump_rel!, 1
tape.add_op :print!, "FALSE!"

tape.run

# tmp = Proc.new do |x| vm.push x end
# vm.add_op DecisionTape::Operation.new :push, tmp

# tmp = Proc.new do
#   x = vm.pop
#   puts "X: #{x}"
#   y = vm.pop
#   puts "Y: #{y}"
#   vm.push x+y
# end

# vm.add_operation DecisionTape::Operation.new :add, tmp

# vm.run_op :push, 9
# vm.run_op :push, 1
# vm.run_op :add

# vm.run_op :exit!, :south
# vm.run_op :exit!, :east

# vm.push room2
# vm.run_op :exit

# tmp = Proc.new do
#   x = vm.pop
#   y = vm.pop
#   vm.push y-x
# end

# vm.add_operation DecisionTape::Operation.new :sub, tmp

# vm.run_op :push, 7
# vm.run_op :sub!, 7

# tmp = Proc.new do
#   x = vm.pop
#   y = vm.pop
#   vm.push x==y
# end

# vm.add_operation DecisionTape::Operation.new :eql, tmp

# vm.run_op :eql?, 3
# vm.run_op :print
