require 'spec_helper'

class A
  def plus(a, b)
    a + b
  end
  
  def minus(a, b)
    a - b
  end
  
  def mult(a, b)
    a * b
  end
  
  def div(a, b)
    a / b
  end
  
  def mod(a, b)
    a % b
  end
  
  def eq(a, b)
    a == b
  end
  
  def lt(a, b)
    a < b
  end
  
  def lte(a, b)
    a <= b
  end
  
  def gt(a, b)
    a > b
  end
  
  def gte(a, b)
    a >= b
  end
  
  def ltlt(a, b)
    a << b
  end
  
  def aref(arr, key)
    arr[key]
  end
  
  def aset(arr, key, val)
    arr[key] = val
  end
  
  def regexpmatch(a, b)
    a =~ /constant/
  end
  
  def regexpmatch2(a, b)
    a =~ b
  end
  
  def test_not(thing)
    !thing
  end
  
  def spaceship(a, b)
    a <=> b
  end
end

describe "Operator Reversal" do
  before do
    @plus_case = DecompilationTestCase.new(A, :plus, <<-EOF)
def plus(a, b)
  a + b
end
EOF
    @minus_case = DecompilationTestCase.new(A, :minus, <<-EOF)
def minus(a, b)
  a - b
end
EOF

    @mult_case = DecompilationTestCase.new(A, :mult, <<-EOF)
def mult(a, b)
  a * b
end
EOF

    @div_case = DecompilationTestCase.new(A, :div, <<-EOF)
def div(a, b)
  a / b
end
EOF
    @mod_case = DecompilationTestCase.new(A, :mod, <<-EOF)
def mod(a, b)
  a % b
end
EOF
    @eq_case = DecompilationTestCase.new(A, :eq, <<-EOF)
def eq(a, b)
  a == b
end
EOF

    @lt_case = DecompilationTestCase.new(A, :lt, <<-EOF)
def lt(a, b)
  a < b
end
EOF

    @lte_case = DecompilationTestCase.new(A, :lte, <<-EOF)
def lte(a, b)
  a <= b
end
EOF
    @gt_case = DecompilationTestCase.new(A, :gt, <<-EOF)
def gt(a, b)
  a > b
end
EOF
    @gte_case = DecompilationTestCase.new(A, :gte, <<-EOF)
def gte(a, b)
  a >= b
end
EOF

    @ltlt_case = DecompilationTestCase.new(A, :ltlt, <<-EOF)
def ltlt(a, b)
  a << b
end
EOF
    @aref_case = DecompilationTestCase.new(A, :aref, <<-EOF)
def aref(arr, key)
  arr[key]
end
EOF

    @aset_case = DecompilationTestCase.new(A, :aset, <<-EOF)
def aset(arr, key, val)
  arr[key] = val
end
EOF

    @regexpmatch = DecompilationTestCase.new(A, :regexpmatch, <<-EOF)
def regexpmatch(a, b)
  a =~ /constant/
end
EOF

    @regexpmatch2 = DecompilationTestCase.new(A, :regexpmatch2, <<-EOF)
def regexpmatch2(a, b)
  a =~ b
end
EOF
    @test_not = DecompilationTestCase.new(A, :test_not, <<-EOF)
def test_not(thing)
  !thing
end
EOF

    @spaceship = DecompilationTestCase.new(A, :spaceship, <<-EOF)
def spaceship(a, b)
  a <=> b
end
EOF
  end
  
  it "can decompile a simple addition of local variables" do
    @plus_case.assert_correct
  end
  
  it "can decompile a simple subtraction of local variables" do
    @minus_case.assert_correct
  end
  
  it "can decompile a simple multiplication of local variables" do
    @mult_case.assert_correct
  end
  
  it "can decompile a simple division of local variables" do
    @div_case.assert_correct
  end
  
  it "can decompile a simple modulus of local variables" do
    @mod_case.assert_correct
  end
  
  it "can decompile a simple equality comparison of local variables" do
    @eq_case.assert_correct
  end
  
  it "can decompile a simple less-than comparison of local variables" do
    @lt_case.assert_correct
  end
  
  it "can decompile a simple less-than-or-equal comparison of local variables" do
    @lte_case.assert_correct
  end
  
  it "can decompile a simple greater-than comparison of local variables" do
    @gt_case.assert_correct
  end
  
  it "can decompile a simple greater-than-or-equal comparison of local variables" do
    @gte_case.assert_correct
  end
  
  it "can decompile a simple left-shift of local variables" do
    @ltlt_case.assert_correct
  end
  
  it "can decompile a simple array-style-reference operator of local variables" do
    @aref_case.assert_correct
  end
  
  it "can decompile a simple array-style-assignment operator of local variables" do
    @aset_case.assert_correct
  end
  
  it "can decompile a simple regexp-matching operator against a constant regexp" do
    @regexpmatch.assert_correct
  end
  
  it "can decompile a simple regexp-matching operator of local variables" do
    @regexpmatch2.assert_correct
  end
  
  it "can decompile a simple not operator on a local variable" do
    @test_not.assert_correct
  end
  
  it "can decompile the shapeship operator" do
    @spaceship.assert_correct
  end
end
