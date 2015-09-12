module Reversal
  module Instructions
    # Send a message without much fanfare. Just a receiver, a method,
    # and maybe some args.     Maybe a block too.
    def do_simple_send(receiver, meth, args = [], block = nil)
      if block
        reverser = Reverser.new(block, self)
        block = r(:block, ISeq.new(block).argstring, reverser.decompile_body)
      end
      push r(:send, meth, receiver, args, block)
    end

    ##
    # Handle a send instruction in the bytecode
    def do_send(meth, argc, blockiseq, op_flag, ic, receiver = nil)
      # [:send, meth, argc, blockiseq, op_flag, inline_cache]
      args = popn(argc)
      receiver ||= pop
      receiver = :implicit if receiver.nil?
      # Special operator cases. Weird, but keep in mind the oddity of
      # using an operator with a block!
      #
      # receiver.[]=(key, val) {|blockarg| ...} is possible!!!
      if !blockiseq
        if meth == :[]=
          remove_useless_dup
          push r(:aset, receiver, args[0], args[1])
          return
        elsif Reverser::ALL_INFIX.include?(meth.to_s)
          push r(:infix, meth, [receiver, args.first])
          return
        end
      end
      ## The rest of cases: either a normal method, a `def`, or an operator with a block
      if meth == :"core#define_method" || meth == :"core#define_singleton_method"
        # args will be [iseq, name, receiver, scope_arg]
        receiver, name, blockiseq = args
        reverser = Reverser.new(blockiseq, self)
        push r(:defmethod, receiver, name, reverser.decompile_body, ISeq.new(blockiseq).argstring)
      # normal method call
      else
        remove_useless_dup if meth == :[]=
        do_simple_send(receiver, meth, args, blockiseq)
      end
    end
    
    def do_super(argc, blockiseq, op_flag)
      args = popn(argc)
      explicit_check = pop
      explicit_args = explicit_check.true?
      args_to_pass = explicit_args ? args : []
      do_simple_send(:implicit, :super, args_to_pass, blockiseq)
    end
    
    #############################
    ###### Variable Lookup ######
    #############################
    def decompile_getlocal(inst, line_no)
      push r(:getvar, get_local(inst[1]))
    end
    
    def decompile_getinstancevariable(inst, line_no)
      push r(:getvar, inst[1])
    end
    alias_method :decompile_getglobal, :decompile_getinstancevariable
    alias_method :decompile_getclassvariable, :decompile_getinstancevariable

    def decompile_getconstant(inst, line_no)
      base = pop
      base_str = (base.nil?) ? "" : "#{base}::"
      push r(:getvar, "#{base_str}#{inst[1]}")
    end
    
    def decompile_getdynamic(inst, line_no)
      push r(:getvar, get_dynamic(inst[1], inst[2]))
    end
    
    def decompile_getspecial(inst, line_no)
      key, type = inst[1..2]
      if type == 0
        # some weird shit i don't get
      elsif (type & 0x01 > 0)
        push r(:getvar, "$#{(type >> 1).chr}")
      else
        push r(:getvar, "$#{(type >> 1)}")
      end
    end
    
    #############################
    ##### Variable Assignment ###
    #############################
    def decompile_setlocal(inst, line_no)
      # [:setlocal, local_num]
      value = pop
      # for some reason, there seems to cause a :dup instruction to be inserted that fucks
      # everything up. So i'll pop the return value.
      remove_useless_dup unless @iseq.type == :top
      push r(:setvar, locals[inst[1] - 1], value)
    end
      
    def decompile_setinstancevariable(inst, line_no)
      # [:setinstancevariable, :ivar_name_as_symbol]
      # [:setglobal, :global_name_as_symbol]
      value = pop
      # for some reason, there seems to cause a :dup instruction to be inserted that fucks
      # everything up. So i'll pop the return value.
      remove_useless_dup
      push r(:setvar, inst[1], value)
    end
    alias_method :decompile_setglobal, :decompile_setinstancevariable
    alias_method :decompile_setclassvariable, :decompile_setinstancevariable

    def decompile_setconstant(inst, line_no)
      # [:setconstant, :const_name_as_symbol]
      name = inst[1]
      scoping_arg, value = pop, pop
      # for some reason, there seems to cause a :dup instruction to be inserted that fucks
      # everything up. So i'll pop the return value.
      remove_useless_dup
      unless scoping_arg.fixnum?
        name = "#{scoping_arg}::#{name}"
      end
      push r(:setvar, name, value)
    end
    
    
    ###################
    ##### Strings #####
    ###################
    def decompile_putstring(inst, line_no)
      push r(:lit, inst[1])
    end
    
    def decompile_tostring(inst, line_no)
      do_simple_send(pop, :to_s)
    end
    
    def decompile_concatstrings(inst, line_no)
      amt = inst[1]
      push r(:infix, :+, pop(amt))
    end
    
    ##################
    ### Arrays #######
    ##################
    
    def decompile_duparray(inst, line_no)
      push r(:lit, inst[1])
    end
    
    def decompile_newarray(inst, line_no)
      # [:newarray, num_to_pop]
      arr = popn(inst[1])
      push r(:array, arr)
    end
    
    def decompile_splatarray(inst, line_no)
      # [:splatarray]
      push r(:splat, pop)
    end
    def decompile_concatarray(inst, line_no)
      # [:concatarray, ignored_boolean_flag]
      arg, receiver = pop, pop
      if receiver.type == :splat
        receiver = receiver[1]
      end
      push r(:infix, :+, [receiver, arg])
    end
      
    ###################
    ### Ranges ########
    ###################
    def decompile_newrange(inst, line_no)
      # [:newrange, exclusive_if_1]
      last, first = pop, pop
      inclusive = (inst[1] != 1)
      push r(:range, first, last, inclusive)

    end
      
    ##############
    ## Hashes ####
    ##############
    def decompile_newhash(inst, line_no)
      # [:newhash, number_to_pop]
      list = []
      0.step(inst[1] - 2, 2) do
        list.unshift [pop, pop].reverse
      end
      push r(:hash, list)
    end
    
    #######################
    #### Weird Stuff ######
    #######################
    def decompile_putspecialobject(inst, line_no)
      # these are for runtime checks - just put the number it asks for, and ignore it
      # later
      push r(:lit, inst[1])
    end
      
    def decompile_putiseq(inst, line_no)
      push inst[1]
    end
      
    ############################
    ##### Stack Manipulation ###
    ############################
    def decompile_setn(inst, line_no)
      # [:setn, num_to_move]
      amt = inst[1]
      val = pop
      @stack[-amt] = val
      push val
    end
    
    def decompile_dup(inst, line_no)
      # [:dup]
      val = pop
      push val
      push val
    end
    def decompile_putobject(inst, line_no)
      # [:putobject, literal]
      push r(:lit, inst[1])
    end
    def decompile_putself(inst, line_no)
      # [:putself]
      push r(:getvar, :self)
    end
    def decompile_putnil(inst, line_no)
      # [:putnil]
      push r(:nil)
    end
    def decompile_swap(inst, line_no)
      a, b = pop, pop
      push b
      push a
    end
    def decompile_opt_aref(inst, line_no)
      # [:opt_aref]
      key, receiver = pop, pop
      push r(:aref, receiver, key)
    end
    def decompile_opt_aset(inst, line_no)
      # [:opt_aset]
      new_val, key, receiver = pop, pop, pop
      push r(:aset, receiver, key, new_val)
    end
    def decompile_opt_not(inst, line_no)
      # [:opt_not]
      receiver = pop
      push r(:not, receiver)
    end
    def decompile_opt_length(inst, line_no)
      # [:opt_length]
      do_simple_send(pop, :length)
    end
    def decompile_opt_succ(inst, line_no)
      # [:opt_succ]
      do_simple_send(pop, :succ)
    end
    def decompile_defined(inst, line_no)
      # [:defined, type, var, needs_string]
      pop # there's a var used for lookups... not necessary for stringification
      do_simple_send(:implicit, :defined?, [inst[2]])
    end
      
    ##############################
    ##### Method Dispatch ########
    ##############################
    def decompile_invokesuper(inst, line_no)
      do_super inst[1], inst[2], inst[3]
    end
    def decompile_invokeblock(inst, line_no)
      do_send :yield, inst[1], nil, inst[2], nil, :implicit
    end
    def decompile_send(inst, line_no)
      # [:send, meth, argc, blockiseq, op_flag, inline_cache]
      do_send *inst[1..-1]
    end
    
    #######################
    ##### Control Flow ####
    #######################
    def decompile_branchunless(inst, line_no, is_unless = false)
      target = inst[1]
      forward = forward_jump?(line_no, target)
      if forward
        # [:getvar, x]
        # [branchunless, :label_1]
        # [:lit, 5]
        # [:jump, :label_2]
        # :label_1
        # [:putnil]
        # :label_5
        #
        #  becomes
        #  if x
        #    nil
        #  else
        #    5
        #  end
        predicate = pop
        reverser = Reverser.new(@iseq, @parent)
        reverser.reset!
        block1 = reverser.decompile_body(line_no + 1, target)
        end_jump_inst = @iseq.body[@iseq.labels[target] - 1]
        if [:jump, :branchunless, :branchif].include? end_jump_inst.first
          block_2_end = end_jump_inst[1]
        else
          block_2_end = @iseq.body.size
        end
        reverser.reset!
        block2 = reverser.decompile_body(@iseq.labels[target], block_2_end)
        if is_unless
          push r(:unless, predicate, block1, block2)
        else
          push r(:if, predicate, block1, block2)
        end
      end
    end
    
    def decompile_branchif(inst, line_no)
      decompile_branchunless(inst, line_no, true)
    end

    def stop_for_while_loop(target, line_no)
      break_table = @iseq.catch_tables.select {|arr| arr.first == :break}
      return nil if break_table.empty?
      break_table = break_table.select {|arr| arr[2] == target}
      raise "Unexpected jump instruction #{target} #{@iseq.body.inspect}" if break_table.empty?
      raise "Unexpected backwards jump #{target} #{@iseq.body.inspect}" unless forward_jump?(line_no, target)
      return break_table.first[3]
    end

    def decompile_jump(inst, line_no)
      target = inst[1]
      start = target
      stop  = stop_for_while_loop(target, line_no)
      return if stop.nil?
      
      reverser = Reverser.new(@iseq, @parent)
      block = reverser.decompile_body(start, stop)
      if block.last == r(:nil)
        block.pop
      end
      pred = block.pop
      push r(:while, pred, block)
    end

    def decompile_throw(inst, line_no)
      # [:throw, level | state]
      # state: 0x01 = return
      #        0x02 = break
      #        0x03 = next
      #        0x04 = "retry" (rescue?)
      #        0x05 = redo
      throw_state = inst[1]
      # not sure what good these all are for decompiling. interesting though.
      state = throw_state & 0xff
      flag  = throw_state & 0x8000
      level = throw_state >> 16
      case state
      when 0x01
        do_simple_send :implicit, :return, [pop]
      when 0x02
        do_simple_send :implicit, :break, [pop]
      when 0x03
        do_simple_send :implicit, :next, [pop]
      when 0x04
        remove_useless_dup #useless nil
        do_simple_send :implicit, :retry
      when 0x05
        remove_useless_dup  #useless nil
        do_simple_send :implicit, :redo
      end
    end
    
    #############################
    ###### Classes/Modules ######
    #############################
    def decompile_defineclass(inst, line_no)
      name, new_iseq, type = inst[1..-1]
      new_iseq = ISeq.new(new_iseq)
      superklass, base = pop, pop
      superklass_as_str = (superklass.nil? ? "" : " < #{superklass}")
      base_as_str = (base.kind_of?(Fixnum) || base.fixnum? ? "" : "#{base}::")
      new_reverser = Reverser.new(new_iseq, self)
      ir = new_reverser.decompile_body
      case type
      when 0 # class
        push r(:general_module, :class, name, ir, [base_as_str, superklass_as_str])
      when 1
        push r(:general_module, :metaclass, name, ir, [base])
      when 2
        push r(:general_module, :module, name, ir, [base_as_str])
      end
    end
    
    ###############################
    ### Inline Cache Simulation ###
    ###############################
    def decompile_getinlinecache(inst, line_no)
      push r(:nil)
    end
    alias_method :decompile_onceinlinecache, :decompile_getinlinecache
    
    def decompile_operator(inst, line_no)
      arg, receiver = pop, pop
      push r(:infix, Reverser::OPERATOR_LOOKUP[inst.first], [receiver, arg])
    end
    
    Reverser::OPERATOR_LOOKUP.keys.each do |operator|
      alias_method "decompile_#{operator}".to_sym, :decompile_operator
    end
  end
end