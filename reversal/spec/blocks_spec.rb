require 'spec_helper'

class A
  def has_a_block(a)
    a.each do |x|
      p x
    end
  end
  
  def has_nested_blocks(a)
    a.each do |x|
      x.each do |y|
        puts y
      end
    end
  end
  
  def returns_from_block_with_value(b)
    b.each do |x|
      return x
    end
  end
  
  def breaks_from_block_with_value(b)
    b.each do |x|
      break x
    end
  end
end

describe "Blocks Reversal" do
  before do
    @has_a_block = DecompilationTestCase.new(A, :has_a_block, <<-EOF)
def has_a_block(a)
  a.each do |x|
    p(x)
  end
end
EOF
    @has_nested_blocks = DecompilationTestCase.new(A, :has_nested_blocks, <<-EOF)
def has_nested_blocks(a)
  a.each do |x|
    x.each do |y|
      puts(y)
    end
  end
end
EOF

    @returns_from_block_with_value = DecompilationTestCase.new(A, :returns_from_block_with_value, <<-EOF)
def returns_from_block_with_value(b)
  b.each do |x|
    return(x)
  end
end
EOF

    @breaks_from_block_with_value = DecompilationTestCase.new(A, :breaks_from_block_with_value, <<-EOF)
def breaks_from_block_with_value(b)
  b.each do |x|
    break(x)
  end
end
EOF
  end
  
  it "can decompile a simple use of a block with one required variable" do
    @has_a_block.assert_correct
  end
  
  it "can decompile nested blocks" do
    @has_nested_blocks.assert_correct
  end
  
  it "can return a value from within a block" do
    @returns_from_block_with_value.assert_correct
  end
  
  it "can break with a value from within a block" do
    @breaks_from_block_with_value.assert_correct
  end
end
