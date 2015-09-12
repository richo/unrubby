require 'spec_helper'

class A
  # shouldn't even use newrange, really
  def uses_a_constant_range
    1..10
  end
  
  def builds_a_simple_range
    x..y
  end
  
  def builds_an_exclusive_range
    hello...world
  end

end

describe "Range Reversal" do
  before do
    @uses_a_constant_range = DecompilationTestCase.new(A, :uses_a_constant_range, <<-EOF)
def uses_a_constant_range
  1..10
end
EOF

    @builds_a_simple_range = DecompilationTestCase.new(A, :builds_a_simple_range, <<-EOF)
def builds_a_simple_range
  (x..y)
end
EOF
    @builds_an_exclusive_range = DecompilationTestCase.new(A, :builds_an_exclusive_range, <<-EOF)
def builds_an_exclusive_range
  (hello...world)
end
EOF

  end

  it "can decompile an range of constants" do
    @uses_a_constant_range.assert_correct
  end
  
  it "can build a simple inclusive range" do
    @builds_a_simple_range.assert_correct
  end
  
  it "can build a simple exclusive range" do
    @builds_an_exclusive_range.assert_correct
  end
end
