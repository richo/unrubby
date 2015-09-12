require "spec_helper"

describe "Odd Reversals" do

  it "reverses calls to defined? for a variable" do
    defined_simple = CompiledDecompilationTestCase.new <<CLASS, <<RESULT
defined? hello
CLASS
defined?(hello)
RESULT
    defined_simple.assert_correct
  end

  it "reverses calls to defined? for a constant" do
    defined_simple = CompiledDecompilationTestCase.new <<CLASS, <<RESULT
defined? HAI
CLASS
defined?(HAI)
RESULT
    defined_simple.assert_correct
  end

  it "reverses the ?x syntax to equivalent code" do
    question_mark = CompiledDecompilationTestCase.new <<CLASS, <<RESULT
?y
CLASS
"y"
RESULT
    question_mark.assert_correct
  end

  it "reverses multi-line branch predicates to equivalent code" do
    question_mark = CompiledDecompilationTestCase.new <<CLASS, <<RESULT
if (x = 10; y = 20; 30)
  nil
else
  10
end
CLASS
x = 10
y = 20
if 30
  nil
else
  10
end
RESULT
    question_mark.assert_correct
  end

end