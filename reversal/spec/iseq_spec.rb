require 'spec_helper'

class SomeTinyClass
  def sillymethod(a, b)
    a.do_something(b)
    b.and_also(a)
  end
end

describe "Instruction Sequence Wrapper" do
  before do
    @raw_empty_iseq = RubyVM::InstructionSequence.compile("")
    
    @raw_simple_seq = RubyVM::InstructionSequence.from_method(SomeTinyClass.new.method(:sillymethod))
    @simple = Reversal::ISeq.new(@raw_simple_seq)
    
    one_with_labels_arr = ["YARVInstructionSequence/SimpleDataFormat", 1, 2,1,
     {:arg_size=>0, :local_size=>1, :stack_max=>2}, "silly", "(irb)", 85, :method,
     [], 0,
     [[:break, nil, :label_10, :label_36, :label_36, 0],
      [:next, nil, :label_10, :label_36, :label_7, 0],
      [:redo, nil, :label_10, :label_36, :label_10, 0]],
     [85, [:trace, 8], 86, [:trace, 1], [:jump, :label_22], [:putnil], :label_7, [:pop], [:jump, :label_22], 
      :label_10, 87, [:trace, 1], [:putnil], [:putstring, "hai"], [:send, :puts, 1, nil, 8, 0], [:pop], 
      :label_22, 86, [:putnil], [:send, :x, 0, nil, 24, 1], [:putobject, 10], [:opt_gt, 3], [:branchif, :label_10], 
      [:putnil], :label_36, 89, [:trace, 16], 86, [:leave]]]
    @iseq_with_labels = Reversal::ISeq.new(one_with_labels_arr)
    @labels_expectation = {:label_7 => 6, :label_10 => 9, :label_22 => 16, :label_36 => 24}
  end
  
  it "can be created with a raw instruction sequence" do
    iseq = Reversal::ISeq.new(@raw_empty_iseq)
    should.not.raise {iseq.validate!}
  end
  
  it "can be created with an instruction sequence in array format" do
    iseq = Reversal::ISeq.new(@raw_empty_iseq.to_a)
    should.not.raise {iseq.validate!}
  end
  
  it "raises an error if initialized unknown version number" do
    should.raise(Reversal::UnknownInstructionSequenceError) do
      Reversal::ISeq.new(["YARVInstructionSequence/SimpleDataFormat", 0, 0, 0])
    end
  end
  
  it "raises an error if validation fails" do
    should.raise(Reversal::InvalidInstructionSequenceError) do
      Reversal::ISeq.new(["Bad Magic", 1, 2, 1]).validate!
    end
  end
  
  it "detects method types" do
    @simple.type.should == :method
  end
  
  it "extracts labels" do
    @iseq_with_labels.labels.should.equal @labels_expectation
  end
end
