require_relative 'fsm'

module FSM
  Cmd = Struct.new :cmd, :obj

  TRANS = :transition
  PUSHK = :push_key
  POP = :pop
  PUSHS = :push_state
  PUSH = :push_current
  RESUME = :resume

  class PushDownAutomata < FiniteStateMachine
    public
    def initialize start, states={}
      super
      @stack = [ ]
    end

    def update data=nil
      puts "PDA: Updating #{@current}" if self.verbose
      if @current
        command = @current.update data
        if command
          if command.instance_of? Cmd
            case command.cmd
            when TRANS
              self.transition command.obj, data
            when PUSHK
              self.push_key command.obj, data
            when POP
              self.pop
            when RESUME
              self.resume data
            when PUSH
              self.push command.obj, data
            when PUSHS
              self.push_state command.obj
            end
          else
            self.transition command, data
          end
        end
      end
    end

    def push key, data=nil
      self.push_state @current
      self.transition key
    end

    def push_key key, data=nil
      state = @states[key]
      if state
        self.push_state state, data
      end
    end

    def push_state state
      @stack.push state
    end

    def pop
      @stack.pop
    end

    def resume data=nil
      state = self.pop
      self.transition state, data
    end

  end # PushDownAutomata

end # FSM
