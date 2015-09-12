require 'spec_helper'

class A

  def makes_an_empty_hash
    {}
  end
  
  def makes_a_simple_hash
    {:hello => :world}
  end
  
  def makes_a_longer_simple_hash
    {:hello => :world, :foo => :bar, :order => :matters}
  end
  
end

describe "Hash Reversal" do
  before do
    @makes_an_empty_hash = DecompilationTestCase.new(A, :makes_an_empty_hash, <<-EOF)
def makes_an_empty_hash
  {}
end
EOF

    @makes_a_simple_hash = DecompilationTestCase.new(A, :makes_a_simple_hash, <<-EOF)
def makes_a_simple_hash
  {:hello => :world}
end
EOF

    @makes_a_longer_simple_hash = DecompilationTestCase.new(A, :makes_a_longer_simple_hash, <<-EOF)
def makes_a_longer_simple_hash
  {:hello => :world, :foo => :bar, :order => :matters}
end
EOF
  end

  it "can decompile an empty hash" do
    @makes_an_empty_hash.assert_correct
  end
  
  it "can decompile a simple hash" do
    @makes_a_simple_hash.assert_correct
  end

  it "can decompile a longer, simple hash, retaining order" do
    @makes_a_longer_simple_hash.assert_correct
  end

end
