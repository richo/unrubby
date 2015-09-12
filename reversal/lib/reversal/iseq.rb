##
# iseq.rb: Wrapper for instruction sequences that won't make you go nuts.
#
# Copyright 2010 Michael J. Edgar, michael.j.edgar@dartmouth.edu
#
# MIT License, see LICENSE file in gem package

module Reversal
  class InvalidInstructionSequenceError < StandardError; end
  class UnknownInstructionSequenceError < StandardError; end
  
  class ISeq
    class << self
      def new(*args)
        # extract the array that represents the instructionsequence
        case args.first
        when SubclassableIseq
          return args.first
        when RubyVM::InstructionSequence
          array = args.first.to_a
        when Array
          array = args.first
        else
          array = args
        end
        # dispatch
        if array[1] == 1
          return VersionOneIseq.new(*array)
        end
        # did not successfully dispatch
        raise UnknownInstructionSequenceError.new("Unknown YARV instruction sequence format: #{array[1]}.#{array[2]}.#{array[3]}")
      end
    end
  end
  
  class SubclassableIseq < Struct.new(:magic, :major_version, :minor_version, :patch_version, :stats,
                                      :name, :filename, :line, :type, :locals, :args, :catch_tables, :body)

    SIMPLE_DATA_FORMAT = "YARVInstructionSequence/SimpleDataFormat"
    def validate!
      unless self.magic == SIMPLE_DATA_FORMAT && "#{version}" >= "1.1.1"
        raise InvalidInstructionSequenceError.new("Invalid YARV instruction sequence in array format: #{self.to_a}")
      end
    end
    
    def version
      "#{major_version}.#{minor_version}.#{patch_version}"
    end

    def complex_args?
      self.args.kind_of? Array
    end

    def body_start
      return 0 unless complex_args?
      arg_opt_labels = self.args[1]
      if arg_opt_labels && arg_opt_labels.any?
        self.labels[arg_opt_labels.last]
      else
        0
      end
    end

    def improve_args(newargs)
      return newargs unless complex_args?
      # format of args array is [required_argc, arg_opt_labels, post_len, post_start, arg_rest, arg_block, arg_simple]
      required_argc, arg_opt_labels, post_len, post_start, arg_rest, arg_block, arg_simple = self.args
      if arg_block > -1
        newargs[arg_block] = "&#{newargs[arg_block]}"
      end
      if arg_rest > -1
        newargs[arg_rest] = "*#{self.locals[arg_rest]}"
      end
      if arg_opt_labels.any?
        reverser = Reverser.new(self, nil)
        old_iseq_type = self.type
        self.type = :top
        (arg_opt_labels.size - 1).times do |idx|
          argidx = required_argc + idx
          reverser.reset!
          puts "argument #{argidx} is from #{arg_opt_labels[idx]} to #{arg_opt_labels[idx + 1]}"
          newargs[argidx] = "#{self.locals[argidx]} = #{reverser.decompile_body(arg_opt_labels[idx], labels[arg_opt_labels[idx + 1]] - 1).to_s(:one_line => true)}"
        end
        self.type = old_iseq_type
      end
      newargs
    end

    def labels
      return @labels if @labels
      result = {}
      self.body.each_with_index do |inst, idx|
        if inst.is_a?(Symbol) && inst.to_s[0..6] = "label_"
          result[inst] = idx
        end
      end
      @labels = result
    end

    def argstring
      return "" if num_args == 0
      args_to_use = self.locals[0...self.num_args]
      args_to_use = improve_args(args_to_use)
      return args_to_use.map {|x| x.to_s}.join(", ")
    end
  end
  
  class VersionOneIseq < SubclassableIseq
    def initialize(*args)
      self.magic = args[0]
      self.major_version = args[1]
      self.minor_version = args[2]
      self.patch_version = args[3]
      self.stats = args[4]
      self.name  = args[5]
      self.filename = args[6]
      self.line = args[7]
      self.type = args[8] # must skip line, not in this version
      self.locals = args[9]
      self.args = args[10]
      self.catch_tables = args[11]
      self.body = args[12]
      
      @labels = nil
    end
    
    def num_args
      self.stats[:arg_size]
    end
  end
end