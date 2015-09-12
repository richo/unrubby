require 'spec_helper'

describe "Control Flow Reversal" do
  before do
    @single_if = CompiledDecompilationTestCase.new <<CLASS, <<RESULT
def test(x)
  if x
    5
  end
end
CLASS
def test(x)
  if x
    5
  end
end
RESULT

    @elsif_branches = CompiledDecompilationTestCase.new <<CLASS, <<RESULT
def test(x)
  if x
    5
  elsif y
    10
  elsif z
    20
  end
end
CLASS
def test(x)
  if x
    5
  elsif y
    10
  elsif z
    20
  end
end
RESULT

    @single_unless = CompiledDecompilationTestCase.new <<CLASS, <<RESULT
def test(x)
  unless x
    5
  end
end
CLASS
def test(x)
  if x
    nil
  else
    5
  end
end
RESULT

    @trailing_if = CompiledDecompilationTestCase.new <<CLASS, <<RESULT
def test(x)
  x = 10 if y
end
CLASS
def test(x)
  if y
    x = 10
  end
end
RESULT

    @trailing_unless = CompiledDecompilationTestCase.new <<CLASS, <<RESULT
def test(x)
  x = 10 unless y
end
CLASS
def test(x)
  if y
    nil
  else
    x = 10
  end
end
RESULT

    @uses_andand = CompiledDecompilationTestCase.new <<CLASS, <<RESULT
def test(x)
  if x && y
    puts(x)
  end
end
CLASS
def test(x)
  if x
    if y
      puts(x)
    end
  end
end
RESULT

    @uses_oror = CompiledDecompilationTestCase.new <<CLASS, <<RESULT
def test(x)
  if x || y
    puts(x)
  end
end
CLASS
def test(x)
  unless x
    if y
      puts(x)
    end
  else
    puts(x)
  end
end
RESULT

    @simple_while = CompiledDecompilationTestCase.new <<CLASS, <<RESULT
begin
  x
end while y
CLASS
begin
  x
end while y
RESULT

    @another_while = CompiledDecompilationTestCase.new <<CLASS, <<RESULT
z = 10
begin
  puts(z)
  z = z - 1
end while z > 0
CLASS
z = 10
begin
  puts(z)
  z = z - 1
end while z > 0
RESULT

  @normal_while = CompiledDecompilationTestCase.new <<CLASS, <<RESULT
while x > 0
  puts(x)
end
CLASS
if x > 0
  begin
    puts(x)
  end while x > 0
end
RESULT
  end
  
  it "can decompile a single if statement" do
    @single_if.assert_correct
  end
  
  it "can decompile elsif branches retaining the structure" do
    @elsif_branches.assert_correct
  end
  
  it "can decompile a simple unless statement to equivalent code" do
    @single_unless.assert_correct
  end
  
  it "can decompile a guard-if statement to equivalent code" do
    @trailing_if.assert_correct
  end
  
  it "can decompile a guard-unless statement to equivalent code" do
    @trailing_unless.assert_correct
  end

  it "can decompile a conditional using the && operator" do
    @uses_andand.assert_correct
  end

  it "can decompile a condition using the || operator" do
    @uses_oror.assert_correct
  end

  it "can decompile simple do..while loops" do
    @simple_while.assert_correct
  end

  it "can decompile a conditional do..while loop" do
    @another_while.assert_correct
  end

  it "can decompile a normal while loop" do
    @normal_while.assert_correct
  end
end