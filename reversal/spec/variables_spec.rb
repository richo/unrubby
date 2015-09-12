require 'spec_helper'

class A
  def simple
    a = 10
    b = 15
  end
  
  def assigns_ivar(val)
    @some_ivar = 5
  end
  
  def assigns_and_gets_ivar
    @some_ivar = @another_ivar
  end

  def assigns_cvar(val)
    @@some_cvar = 5
  end

  def assigns_and_gets_cvar
    @@some_cvar = @@another_cvar
  end

  def set_global_var
    $aloha = 10
  end
  
  def get_global_var
    $_
  end
  
  def get_special_var_ampersand
    $&
  end
  
  def get_special_var_backtick
    $`
  end
  
  def get_special_var_number
    $3
  end
  
  def get_constant
    ALOHA
  end
  
  def get_nested_constant
    HELLO::WORLD
  end
end

describe "Variable Assignment/Retrieval Reversal" do
  before do
    @simple_case = DecompilationTestCase.new(A, :simple, <<-EOF)
def simple
  a = 10
  b = 15
end
EOF

    @assigns_ivar_case = DecompilationTestCase.new(A, :assigns_ivar, <<-EOF)
def assigns_ivar(val)
  @some_ivar = 5
end
EOF

    @assigns_ivar_set_get_case = DecompilationTestCase.new(A, :assigns_and_gets_ivar, <<-EOF)
def assigns_and_gets_ivar
  @some_ivar = @another_ivar
end
EOF


    @assigns_cvar_case = DecompilationTestCase.new(A, :assigns_cvar, <<-EOF)
def assigns_cvar(val)
  @@some_cvar = 5
end
EOF

    @assigns_cvar_set_get_case = DecompilationTestCase.new(A, :assigns_and_gets_cvar, <<-EOF)
def assigns_and_gets_cvar
  @@some_cvar = @@another_cvar
end
EOF

    @set_global_var_case = DecompilationTestCase.new(A, :set_global_var, <<-EOF)
def set_global_var
  $aloha = 10
end
EOF

    @get_global_var_case = DecompilationTestCase.new(A, :get_global_var, <<-EOF)
def get_global_var
  $_
end
EOF

    @get_special_var_ampersand = DecompilationTestCase.new(A, :get_special_var_ampersand, <<-EOF)
def get_special_var_ampersand
  $&
end
EOF
  
    @get_special_var_backtick = DecompilationTestCase.new(A, :get_special_var_backtick, <<-EOF)
def get_special_var_backtick
  $`
end
EOF
  
    @get_special_var_number = DecompilationTestCase.new(A, :get_special_var_number, <<-EOF)
def get_special_var_number
  $3
end
EOF


    @set_constant = CompiledDecompilationTestCase.new("ALOHA = 10", "ALOHA = 10")
    @set_constant_base = CompiledDecompilationTestCase.new("Silly::ALOHA = 10", "Silly::ALOHA = 10")
    
    @get_constant = DecompilationTestCase.new(A, :get_constant, <<-EOF)
def get_constant
  ALOHA
end
EOF

    @get_nested_constant = DecompilationTestCase.new(A, :get_nested_constant, <<-EOF)
def get_nested_constant
  HELLO::WORLD
end
EOF
  end
  
  it "can decompile a method with simple local assignments" do
    @simple_case.assert_correct
  end
  
  it "can decompile a method that assigns an instance variable" do
    @assigns_ivar_case.assert_correct
  end
  
  it "can decompile a method that assigns and gets an instance variable" do
    @assigns_ivar_set_get_case.assert_correct
  end

  it "can decompile a method that assigns a class variable" do
    @assigns_cvar_case.assert_correct
  end

  it "can decompile a method that assigns and gets a class variable" do
    @assigns_cvar_set_get_case.assert_correct
  end
  
  it "can decompile a method assigning a global variable" do
    @set_global_var_case.assert_correct
  end
  
  it "can decompile a method retrieving a global variable" do
    @get_global_var_case.assert_correct
  end
  
  it "can decompile a method using the $& special variable" do
    @get_special_var_ampersand.assert_correct
  end
  
  it "can decompile a method using the $` special variable" do
    @get_special_var_backtick.assert_correct
  end
  
  it "can decompile a method using the $(digit) special variables" do
    @get_special_var_number.assert_correct
  end
  
  it "can decompile the simplest case for setting a constant" do
    @set_constant.assert_correct
  end

  it "can decompile setting a constant with a base" do
    @set_constant_base.assert_correct
  end
  
  it "can decompile the retrieval of a constant" do
    @get_constant.assert_correct
  end
  
  it "can decompile a constant with a base" do
    @get_nested_constant.assert_correct
  end
end
