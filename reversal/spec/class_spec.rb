require 'spec_helper'

describe "Class Reversal" do
  
  before do
    @empty_class = CompiledDecompilationTestCase.new <<CLASS, <<RESULT
class A
end
CLASS
class A
  nil
end
RESULT

    @nonempty_class = CompiledDecompilationTestCase.new <<CLASS, <<RESULT
class A
  attr_accessor :hello
end
CLASS
class A
  attr_accessor(:hello)
end
RESULT

    @class_with_base = CompiledDecompilationTestCase.new <<CLASS, <<RESULT
class B::C::A
  attr_accessor :hello
end
CLASS
class B::C::A
  attr_accessor(:hello)
end
RESULT

    @simple_module = CompiledDecompilationTestCase.new <<CLASS, <<RESULT
module A
  module_function :silly
end
CLASS
module A
  module_function(:silly)
end
RESULT

    @simple_singleton_class = CompiledDecompilationTestCase.new <<CLASS, <<RESULT
class << self
  x = self
end
CLASS
class << self
  x = self
end
RESULT

    @class_with_method = CompiledDecompilationTestCase.new <<CLASS, <<RESULT
class A
  def silly
    5
  end
end
CLASS
class A
  def silly
    5
  end
end
RESULT

    @class_with_singleton_method = CompiledDecompilationTestCase.new <<CLASS, <<RESULT
class A
  def self.silly
    5
  end
end
CLASS
class A
  def self.silly
    5
  end
end
RESULT

    @class_include_call = CompiledDecompilationTestCase.new <<CLASS, <<RESULT
class A
  include SomeModule
  extend AnotherModule
end
CLASS
class A
  include(SomeModule)
  extend(AnotherModule)
end
RESULT

    @longer_singleton_class = CompiledDecompilationTestCase.new <<CLASS, <<RESULT
class << self
  x = self
  push x
  map x
end
CLASS
class << self
  x = self
  push(x)
  map(x)
end
RESULT

    @longer_module = CompiledDecompilationTestCase.new <<CLASS, <<RESULT
module Hello
  x = self
  push x
  map x
end
CLASS
module Hello
  x = self
  push(x)
  map(x)
end
RESULT

    
  end
  
  it "decompiles an empty class" do
    @empty_class.assert_correct
  end
  
  it "decompiles a class with some executable code (but no defs)" do
    @nonempty_class.assert_correct
  end
  
  it "decompiles classes with bases" do
    @class_with_base.assert_correct
  end
  
  it "decompiles a simple module" do
    @simple_module.assert_correct
  end
  
  it "decompiles access to singleton classes" do
    @simple_singleton_class.assert_correct
  end
  
  it "decompiles a class with a method" do
    @class_with_method.assert_correct
  end
  
  it "decompiles a class with a singleton method (`def self.meth` syntax)" do
    @class_with_singleton_method.assert_correct
  end
  
  it "decompiles a class calling `include`" do
    @class_include_call.assert_correct
  end
  
  it "decompiles longer singleton classes" do
    @longer_singleton_class.assert_correct
  end
  
  it "decompiles longer modules" do
    @longer_module.assert_correct
  end
end