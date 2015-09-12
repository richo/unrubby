require 'spec_helper'

class A
  
  def has_one_arg(a)
  end
  
  def has_two_args(a,b,c)
  end
  
  def calls_a_method
    5.minutes()
  end
  
  def first_multiline(arg)
    hello = arg.crazy
    puts(hello)
  end
  
  def chained_methods(arg1, arg2)
    arg1.a_method(arg1, arg2).another_method.to_s
  end
  
  def length_test(arg1)
    arg1.length
  end
  
  def succ_test(arg1)
    arg1.succ
  end
  
  def use_super(arg, other)
    super arg
  end
  
  def use_super_implicitly(arg, other)
    super
  end
  
  def use_yield(arg, another)
    yield another, arg
  end
  
  def has_block_param(arg, &blk)
    puts blk
  end
  
  def has_end_rest_arg(arg, *rest)
    p rest
  end
  
  def has_rest_in_middle(arg, *rest, another, second)
    p second
  end

  def has_optional_argument(a1, a2, a3 = 5)
    p a1
  end

  def has_optional_arguments(a1, a2, a3 = 5, a4 = a3)
    p a1
  end

  def has_trailing_required_argument(a1, a2, a3 = 5, a4 = a3, a5)
    p a1
  end

  def has_multiline_optional_argument(a1, a2, a3 = (a4 = a1; a1 = a2; a2 = a4; 10))
    p a1
  end
end

describe "Method Reversal" do
  before do
    
    @one_arg_case = DecompilationTestCase.new(A, :has_one_arg, <<-EOF)
def has_one_arg(a)
  nil
end
EOF
    
    @two_arg_case = DecompilationTestCase.new(A, :has_two_args, <<-EOF)
def has_two_args(a, b, c)
  nil
end
EOF
    
    @calls_a_method_case = DecompilationTestCase.new(A, :calls_a_method, <<-EOF)
def calls_a_method
  5.minutes
end
EOF

    @first_multiline_case = DecompilationTestCase.new(A, :first_multiline, <<-EOF)
def first_multiline(arg)
  hello = arg.crazy
  puts(hello)
end
EOF

    @chained_method_case = DecompilationTestCase.new(A, :chained_methods, <<-EOF)
def chained_methods(arg1, arg2)
  arg1.a_method(arg1, arg2).another_method.to_s
end
EOF

    @length_test = DecompilationTestCase.new(A, :length_test, <<-EOF)
def length_test(arg1)
  arg1.length
end
EOF

    @succ_test = DecompilationTestCase.new(A, :succ_test, <<-EOF)
def succ_test(arg1)
  arg1.succ
end
EOF
    @use_super = DecompilationTestCase.new(A, :use_super, <<-EOF)
def use_super(arg, other)
  super(arg)
end
EOF
    @use_super_implicitly = DecompilationTestCase.new(A, :use_super_implicitly, <<-EOF)
def use_super_implicitly(arg, other)
  super
end
EOF
    @use_yield = DecompilationTestCase.new(A, :use_yield, <<-EOF)
def use_yield(arg, another)
  yield(another, arg)
end
EOF

    @has_block_param = DecompilationTestCase.new(A, :has_block_param, <<-EOF)
def has_block_param(arg, &blk)
  puts(blk)
end
EOF
    @has_end_rest_arg = DecompilationTestCase.new(A, :has_end_rest_arg, <<-EOF)
def has_end_rest_arg(arg, *rest)
  p(rest)
end
EOF

    @has_rest_in_middle = DecompilationTestCase.new(A, :has_rest_in_middle, <<-EOF)
def has_rest_in_middle(arg, *rest, another, second)
  p(second)
end
EOF

    @has_one_optional_arg = DecompilationTestCase.new(A, :has_optional_argument, <<-EOF)
def has_optional_argument(a1, a2, a3 = 5)
  p(a1)
end
EOF

    @has_two_optional_args = DecompilationTestCase.new(A, :has_optional_arguments, <<-EOF)
def has_optional_arguments(a1, a2, a3 = 5, a4 = a3)
  p(a1)
end
EOF

    @has_trailing_required_arg = DecompilationTestCase.new(A, :has_trailing_required_argument, <<-EOF)
def has_trailing_required_argument(a1, a2, a3 = 5, a4 = a3, a5)
  p(a1)
end
EOF

    @has_multiline_optional_arg = DecompilationTestCase.new(A, :has_multiline_optional_argument, <<-EOF)
def has_multiline_optional_argument(a1, a2, a3 = (a4 = a1; a1 = a2; a2 = a4; 10))
  p(a1)
end
EOF

  end
  
  it "can decompile a method with one positional argument" do
    @one_arg_case.assert_correct
  end
  
  it "can decompile a method with two positional arguments" do
    @two_arg_case.assert_correct
  end
  
  it "can decompile a method being called" do
    @calls_a_method_case.assert_correct
  end
  
  it "can handle a complex multiline decompilation" do
    @first_multiline_case.assert_correct
  end
  
  it "decompiles chained methods appropriately" do
    @chained_method_case.assert_correct
  end
  
  it "decompiles a call to length" do
    @length_test.assert_correct
  end
  
  it "decompiles a call to succ" do
    @succ_test.assert_correct
  end
  
  it "decompiles a call to super with explicit arguments" do
    @use_super.assert_correct
  end
  
  it "decompiles a call to super with implicit arguments" do
    @use_super_implicitly.assert_correct
  end
  
  it "decompiles a call to yield" do
    @use_yield.assert_correct
  end
  
  it "decompiles methods with block parameters" do
    @has_block_param.assert_correct
  end
  
  it "decompiles methods with a rest argument at the end" do
    @has_end_rest_arg.assert_correct
  end
  
  it "decompiles methods with a rest argument in the middle" do
    @has_rest_in_middle.assert_correct
  end

  it "decompiles methods with a single optional argument" do
    @has_one_optional_arg.assert_correct
  end

  it "decompiles methods with two optional arguments" do
    @has_two_optional_args.assert_correct
  end

  it "decompiles methods with a trailing required argument" do
    @has_trailing_required_arg.assert_correct
  end

  it "decompiles a multiline optional argument" do
    @has_multiline_optional_arg.assert_correct
  end
end
