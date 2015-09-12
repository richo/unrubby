##
# reversal.rb: Reverser dispatcher for different types of decompilable code.
# 
#
# Copyright 2010 Michael J. Edgar, michael.j.edgar@dartmouth.edu
#
# MIT License, see LICENSE file in gem package

module Reversal
  class Reverser
    OPERATOR_LOOKUP = {:opt_plus => "+", :opt_minus => "-", :opt_mult => "*", :opt_div => "/",
                       :opt_mod => "%", :opt_eq => "==", :opt_neq => "!=", :opt_lt => "<",
                       :opt_le => "<=", :opt_gt => ">", :opt_ge => ">=", :opt_ltlt => "<<",
                       :opt_regexpmatch2 => "=~"}
                       
    # Instructions module depends on OPERATOR_LOOKUP
    include Instructions
    
    TAB_SIZE = 2          
    ALL_INFIX = OPERATOR_LOOKUP.values + ["<=>"]
    attr_accessor :locals, :parent, :indent
    
    def initialize(iseq, parent=nil)
      @iseq = ISeq.new(iseq)
      @iseq.validate!
      
      @parent = parent
      @locals = [:self] + @iseq.locals.reverse
      reset!
    end
    
    def reset!
      @stack = []
      @else_stack = []
      @end_stack  = []
    end

        # include specific modules for different reversal techniques
    def to_ir
      reset!
      # dispatch on the iseq type
      self.__send__("to_ir_#{@iseq.type}".to_sym, @iseq)
    end

    def to_ir_block(iseq)
      return r(:block, @iseq.argstring, decompile_body)
    end

    def to_ir_method(iseq)
      reverser = Reverser.new(iseq, self)
      iseq = ISeq.new(iseq)
      return r(:defmethod, r(:lit, 0), iseq.name, reverser.decompile_body, iseq.argstring)
    end

    ##
    # If it's just top-level code, then there are no args - just decompile
    # the body straight away
    def to_ir_top(iseq)
      decompile_body
    end

    ##
    # If it's just top-level code, then there are no args - just decompile
    # the body straight away
    def to_ir_class(iseq)
      decompile_body
    end

    ##
    # Gets a local variable at the given bytecode-style index
    def get_local(idx)
      get_dynamic(idx, 0)
    end
    
    ##
    # Gets a dynamic variable, based on the bytecode-style index and
    # the depth
    def get_dynamic(idx, depth)
      if depth == 0
        @locals[idx - 1]
      elsif @parent
        @parent.get_dynamic(idx, depth - 1)
      else
        raise "Invalid dynamic variable requested: #{idx} #{depth} from #{self.iseq}"
      end
    end 
    
    ##
    # Pushes a node onto the stack, as a decompiled string
    def push(str)
      @stack.push str
    end
    
    ##
    # Pops a node from the stack, as a decompiled string
    def pop(n = 1)
      if @stack.empty?
        raise "Popped an empty stack"
      elsif n == 1
        @stack.pop
      else
        popn(n)
      end
    end
    
    def popn(n = 1)
      (1..n).to_a.map {pop}.reverse
    end
    
    def remove_useless_dup
      pop unless @stack.empty?
    end
    
    TRACE_NEWLINE = 1
    TRACE_EXIT = 16
    
    def forward_jump?(current, label)
      @iseq.labels[label] && @iseq.labels[label] > current
    end
    
    def backward_jump?(current, label)
      !forward_jump?(current, label)
    end

    def next_instruction_number(cur_inst, cur_line)
      if cur_inst.is_a?(Array)
        if (cur_inst[0] == :branchif || cur_inst[0] == :branchunless)
          if forward_jump?(cur_line,cur_inst[1])
            target = cur_inst[1]
            location_of_target = @iseq.labels[target]
            else_instruction = @iseq.body[location_of_target - 1]
            if else_instruction.first == :jump
              else_target = else_instruction[1]
              location_of_else_target = @iseq.labels[else_target]
              return location_of_else_target
            else
              return @iseq.body.size + 1
            end
          end
        elsif cur_inst[0] == :leave
          return @iseq.body.size + 1
        elsif cur_inst[0] == :jump
          stopper = stop_for_while_loop(cur_inst[1], cur_line)
          if stopper
            return @iseq.labels[stopper]
          end
        end
      end
      return cur_line + 1
    end

    def decompile_body(instruction = @iseq.body_start, stop = @iseq.body.size)
      if instruction.is_a?(Symbol)
        instruction = @iseq.labels[instruction]
      end
      if stop.is_a?(Symbol)
        stop = @iseq.labels[stop]
      end
      # for now, using non-idiomatic while loop bc of a chance we might need to
      # loop back
      iseq = @iseq
      while instruction < stop do
        inst = iseq.body[instruction]
        #p inst, @stack
        #puts "Instruction #{instruction} #{inst.inspect} #{@stack.inspect}"
        case inst
        when Integer
          # x
          @current_line = inst    # unused
        when Symbol
          # :label_y
        when Array
          # [:instruction, *args]
          # call "decompile_#{instruction}"
          send("decompile_#{inst.first}".to_sym, inst, instruction) if respond_to?("decompile_#{inst.first}".to_sym)
        end
        instruction = next_instruction_number(inst, instruction)
      end
      r(:list, *@stack)
    end
    
  end
end