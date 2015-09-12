require 'spec_helper'

class A
  def uses_a_string
    var = "a string"
  end
  
  def interpolates_a_string
    "hello #{world_method}"
  end

end

describe "String Reversal" do
  before do
    @uses_a_string_case = DecompilationTestCase.new(A, :uses_a_string, <<-EOF)
def uses_a_string
  var = "a string"
end
EOF

    @interpolates_a_string_case = DecompilationTestCase.new(A, :interpolates_a_string, <<-EOF)
def interpolates_a_string
  "hello " + world_method.to_s
end
EOF

  end

  it "can decompile a simple expression with a string" do
    @uses_a_string_case.assert_correct
  end
  
  it "interpolates a simple string" do
    @interpolates_a_string_case.assert_correct
  end
end
