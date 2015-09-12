##
# reversal.rb: decompiling YARV instruction sequences
#
# Copyright 2010 Michael J. Edgar, michael.j.edgar@dartmouth.edu
#
# MIT License, see LICENSE file in gem package

$:.unshift(File.dirname(__FILE__))

module Reversal
  autoload :Instructions, "reversal/instructions"
end

require 'reversal/ir'
require 'reversal/iseq'
require 'reversal/reverser'


module Reversal
  VERSION = "0.9.0"
  
  class << self
    def decompile(iseq)
      Reverser.new(iseq).to_ir.to_s
    end
  end
end