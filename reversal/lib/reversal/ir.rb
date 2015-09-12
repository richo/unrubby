module Reversal
  class UnsupportedFieldException < StandardError; end
  class Sexp < Array
    def initialize(*args)
      super
      if self.respond_to?("post_init_#{self.type}".to_sym)
        send("post_init_#{self.type}".to_sym)
      end
    end

    def type
      self.first
    end
    def body
      self[1..-1]
    end

    def simple?
      ![:infix, :if, :unless, :setvar, :aset, :general_module, :defmethod, :block].include?(self.type)
    end

    def nil?
      self.type == :nil
    end

    def true?
      self.type == :lit && self[1] == true
    end

    def fixnum?
      self.type == :lit && self[1].is_a?(Fixnum)
    end

    def indent(amt = 2)
      if self.type != :list
        raise UnsupportedFieldException.new("Only list sexps can be indented.")
      end
      1.upto(self.size - 1) do |idx|
        self[idx] = self[idx].to_s.split("\n").map {|x| " " * amt + x.to_s}.join("\n")
      end
      self
    end

    def to_s(options = {})
      if self.respond_to?("to_s_#{self.type}".to_sym)
        send("to_s_#{self.type}".to_sym, options)
      else
        super()
      end
    end

    ####### to_s methods #########
    def to_s_lit(options = {})
      # [:lit, 5]
      self[1].inspect
    end

    def to_s_getvar(options = {})
      # [:getvar, :HELLO]
      # [:getvar, :@hello]
      self[1].to_s
    end

    def to_s_setvar(options = {})
      "#{self[1]} = #{self[2]}"
    end

    def to_s_splat(options = {})
      "*#{self[1]}"
    end

    def to_s_list(options = {})
      if options[:one_line]
        result = self.body.map {|x| x.to_s.lstrip}.join("; ")
        if self.body.size > 1
          result = "(#{result})"
        end
        result
      else
        self.body.map {|x| x.to_s}.join("\n")
      end
    end

    def to_s_array(options = {})
      "[#{self[1].map {|x| x.to_s}.join(", ")}]"
    end

    def to_s_range(options = {})
      start, stop, flag = self[1..-1]
      if flag # inclusive?
        "(#{start}..#{stop})"
      else
        "(#{start}...#{stop})"
      end
    end

    def to_s_infix(options = {})
      operator, args  = self[1], self[2]
      need_parens = (args.all? {|x| x.is_a?(Sexp) && x.simple?})
      if need_parens
        args.map {|a| a.to_s}.join(" #{operator} ")
      else
        args = args.map do |arg|
          arg.simple? ? arg.to_s : "(#{arg.to_s})"
        end
        "(" + args.join(" #{operator} ") + ")"
      end
    end

    def to_s_hash(options = {})
      list = self[1]
      list.map! {|(k, v)| "#{k} => #{v}" }
      "{#{list.join(', ')}}"
    end

    def to_s_nil(options = {})
      "nil"
    end

    def to_s_not(options = {})
      "!#{self[1]}"
    end

    def to_s_aref(options = {})
      "#{self[1]}[#{self[2]}]"
    end

    def to_s_aset(options = {})
      "#{self[1]}[#{self[2]}] = #{self[3]}"
    end

    def to_s_block(options = {})
      args, body = self.body
      args = " |#{args}|" if args != ""
      result = []
      result << " do#{args}"
      result << body.indent.to_s
      result << "end"
      result.join("\n")
    end

    def to_s_defmethod(options = {})
      receiver, name, code, argstring = self.body
      # prep arguments
      args = argstring
      args = "(#{args})" if args != ""
      # prep method name if necessary
      name = name.to_s
      name = name[1..-1] if name[0,1] == ":" # cut off leading :
      name = receiver.fixnum? ? "#{name}" : "#{receiver}.#{name}"
      # output result
      result = []
      result << "def #{name}#{args}"
      result << code.indent.to_s
      result << "end"
      result.join("\n")
    end


    ##
    # Send IR: r(:send, method, receilver, args, blockiseq)
    # method: symbol or string
    # receiver: string or Sexp or :implicit for none
    # args: Array ?
    # blockiseq: :block Sexp
    def to_s_send(options = {})
      meth, receiver, args, blockiseq = self.body
      result = meth.to_s
      result = "#{receiver}.#{result}" unless receiver == :implicit
      result << (args.any? ? "(#{args.map {|a| a.to_s}.join(", ")})" : "")

      if blockiseq
        result << blockiseq.to_s
      end
      result
    end

    def to_s_general_module(options = {})
      type, name, ir, data = self.body
      case type
      when :module
        first_line = "module #{data[0]}#{name}"
      when :metaclass
        first_line = "class << #{data[0]}"
      when :class
        first_line = "class #{data[0]}#{name}#{data[1]}"
      else
        raise ArgumentError.new("Incorrect type of general module provided: #{type.inspect}")
      end
      result = []
      result << first_line
      result << ir.indent.to_s
      result << "end"
      result.join("\n")
    end

    def to_s_if(options = {})
      predicate, ifblock, elseblock = self.body
      result = []
      result << "if #{predicate.to_s}"
      result << ifblock.indent.to_s
      if elseblock.body.size == 1 && elseblock.body.first.type == :if
        # chain to the next if!
        result << "els" + elseblock.body.first.to_s
      else
        # got a real else block? then do it here.
        if elseblock != r(:list, r(:nil))
          result << "else"
          result << elseblock.indent.to_s
        end
        result << "end"
      end
      result.join("\n")
    end

    def to_s_unless(options = {})
      predicate, ifblock, elseblock = self.body
      result = []
      result << "unless #{predicate.to_s}"
      result << ifblock.indent.to_s
      result << "else"
      result << elseblock.indent.to_s
      result << "end"
      result.join("\n")
    end

    def to_s_while(options = {})
      pred, block = self.body
      result = []
      result << "begin"
      result << block.indent.to_s
      result << "end while #{pred}"
      result.join("\n")
    end
  end
end

module Kernel
  def r(*args)
    Reversal::Sexp.new(args)
  end
end