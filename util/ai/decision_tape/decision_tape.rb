module DecisionTape

  TapeOp = Struct.new :op, :arg

  class TapeStrip
    TAPE_START  = :dt_start
    TAPE_END  = :dt_end

    attr_accessor :ops
    attr_accessor :vm

    def initialize vm=nil
      @ops = [ ]
      @vm = vm
      # @ops << TapeOp.new TAPE_START, nil
    end

    def add_op op, arg
      @ops << TapeOp.new(op, arg)
    end

    def end
      # @ops << TapeOp.new TAPE_END, nil
    end

    def run
      @vm.jump 0
      while @vm.pc < @ops.count
        op = @ops[@vm.pc]
        @vm.run_op op.op, op.arg
        @vm.inc_pc
      end
    end

  end

end