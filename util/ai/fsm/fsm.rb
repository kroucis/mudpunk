module FSM
  class State
    public
    def initialize
    end

    def enter data
    end

    def update data
    end

    def exit data
    end

  end # State

  class FiniteStateMachine < State
    public

    attr_accessor :verbose

    def initialize start, states={}
      @states = states
      @current = nil
      @verbose = false
      self.transition start
    end

    def []= key, state
      if state == nil
        @states.delete key
      else
        @states[key] = state
      end
    end

    def update data=nil
      puts "FSM: Updating #{@current}" if self.verbose
      new_state = @current.update data
      puts "FSM: Update result was #{new_state}" if self.verbose
      if new_state
        self.transition new_state, data
      end
    end

    def transition key, data=nil
      puts "FSM: Transition #{key}" if self.verbose
      puts "FSM: State was #{@current}" if self.verbose
      if @current
        @current.exit data
      end
      puts "FSM: Transitioning to #{key} -> #{@states[key]}" if self.verbose
      @current = @states[key]
      if @current
        @current.enter data
      end
    end

    def print_states
      puts "FSM: @states"
    end

  end # FiniteStateMachine

end # FSM
