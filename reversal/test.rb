require './lib/reversal.rb'

iseq = RubyVM::InstructionSequence.new(File.read(__FILE__))

# puts iseq.to_a.last.inspect
puts Reversal.decompile(iseq)
