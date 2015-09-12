require 'spec_helper'

describe "Intermediate Representation Strinfication" do

  it "converts list sexps" do
    r(:list, "5", "10").to_s.should.equal("5\n10")
  end

  it "converts indented list sexps" do
    r(:list, "5", "10").indent.to_s.should.equal("  5\n  10")
  end

  it "converts arbitrarily indented list sexps" do
    r(:list, "5", "10").indent(5).to_s.should.equal("     5\n     10")
  end

  it "converts list sexps with the one-line option" do
    r(:list, "5", "10").to_s(:one_line => true).should.equal("(5; 10)")
  end

  it "strips whitespace when converting 1-line list sexps" do
    r(:list, "5", "10").indent(10).to_s(:one_line => true).should.equal("(5; 10)")
  end

  it "converts literal integers" do
    r(:lit, 5).to_s.should.equal "5"
  end

  it "converts literal strings" do
    r(:lit, "hello").to_s.should.equal "\"hello\""
  end

  it "converts local getvar expressions" do
    r(:getvar, "somevar").to_s.should.equal "somevar"
  end

  it "converts ivar getvar expressions" do
    r(:getvar, "@some_ivar").to_s.should.equal "@some_ivar"
  end

  it "converts constant getvar expressions" do
    r(:getvar, :SOME_CONSTANT).to_s.should.equal "SOME_CONSTANT"
  end

  it "converts local setvar expressions" do
    r(:setvar, "some_var", "some_value").to_s.should.equal "some_var = some_value"
  end

  it "converts constant setvar expressions" do
    r(:setvar, "A_CONSTANT", r(:lit, 5)).to_s.should.equal "A_CONSTANT = 5"
  end

  it "converts splat expressions" do
    r(:splat, r(:lit, [1, 2, 3, 4])).to_s.should.equal "*[1, 2, 3, 4]"
  end

  it "converts array literal expressions" do
    r(:array, [r(:lit, 3), r(:lit, :hello)]).to_s.should.equal "[3, :hello]"
  end

  it "converts inclusive range literal expressions" do
    r(:range, r(:lit, "aaa"), r(:lit, "zzz"), true).to_s.should.equal "(\"aaa\"..\"zzz\")"
  end

  it "converts exclusive range literal expressions" do
    r(:range, r(:lit, 3), r(:lit, 300), false).to_s.should.equal "(3...300)"
  end

  it "converts a simple infix expression" do
    r(:infix, :+, [r(:lit, 3), r(:lit, 4)]).to_s.should.equal "3 + 4"
  end

  it "converts an infix expression with many arguments" do
    r(:infix, :*, [r(:lit, "hi"), r(:lit, 3), r(:lit, 20)]).to_s.should.equal "\"hi\" * 3 * 20"
  end

  it "converts a complex infix expression, introducing parentheses" do
    r(:infix, :+, [r(:lit, 3), r(:setvar, "avar", 10)]).to_s.should.equal("(3 + (avar = 10))")
  end

  it "converts a hash literal" do
    ir = r(:hash, [[r(:lit, :key), r(:lit, :value)], [r(:lit, "hello"), r(:lit, "world")]])
    ir.to_s.should.equal "{:key => :value, \"hello\" => \"world\"}"
  end

  it "converts nil literals" do
    r(:nil).to_s.should.equal "nil"
  end

  it "converts not expressions" do
    r(:not, r(:lit, "something")).to_s.should.equal "!\"something\""
  end

  it "converts array reference expressions" do
    r(:aref, r(:getvar, :ahash), r(:lit, :akey)).to_s.should.equal "ahash[:akey]"
  end

  it "converts array setting expressions" do
    r(:aset, r(:getvar, :ahash), r(:lit, :akey), r(:lit, 5)).to_s.should.equal "ahash[:akey] = 5"
  end

  it "converts blocks with no arguments" do
    ir = r(:block, "", r(:list, r(:getvar, "avar"), r(:setvar, "avar", r(:lit, 5))))
    ir.to_s.should.equal(" do\n  avar\n  avar = 5\nend")
  end

  it "converts blocks with arguments" do
    ir = r(:block, "arg1, *rest", r(:list, r(:getvar, "avar"), r(:setvar, "avar", r(:lit, 5))))
    ir.to_s.should.equal(" do |arg1, *rest|\n  avar\n  avar = 5\nend")
  end

  it "converts method calls with no receiver or arguments" do
    ir = r(:send, :sillymethod, :implicit, [], nil)
    ir.to_s.should.equal("sillymethod")
  end

  it "converts method calls with a receiver but no arguments" do
    ir = r(:send, :sillymethod, r(:lit, 5), [], nil)
    ir.to_s.should.equal("5.sillymethod")
  end

  it "converts method calls with a receiver and a simple argument" do
    ir = r(:send, :sillymethod, r(:lit, "hello"), [r(:getvar, "arg")], nil)
    ir.to_s.should.equal("\"hello\".sillymethod(arg)")
  end

  it "converts method calls with a receiver and two complex argument" do
    ir = r(:send, :sillymethod, r(:lit, "hello"), [r(:infix, :+, [r(:lit, 5), r(:lit, 10)]),
                                                   r(:send, :puts, :implicit, [r(:getvar, "hello")], nil)], nil)
    ir.to_s.should.equal("\"hello\".sillymethod(5 + 10, puts(hello))")
  end

  it "converts method calls with an operator in the ugly manner" do
    ir = r(:send, :+, r(:lit, 5), [r(:lit, 10)], nil)
    ir.to_s.should.equal("5.+(10)")
  end

  it "converts implicit method calls with the []= operator in an ugly manner" do
    ir = r(:send, :[]=, r(:getvar, "hash"), [r(:getvar, "key"), r(:getvar, "value")], nil)
    ir.to_s.should.equal("hash.[]=(key, value)")
  end

  it "converts a method send with a block" do
    block = r(:block, "", r(:list, r(:getvar, "avar"), r(:setvar, "avar", r(:lit, 5))))
    ir = r(:send, :sillymethod, :implicit, [], block)
    ir.to_s.should.equal("sillymethod do\n  avar\n  avar = 5\nend")
  end

  it "converts a complex block with a complex method send" do
    block = r(:block, "arg1, *rest", r(:list, r(:getvar, "avar"), r(:setvar, "avar", r(:lit, 5))))
    ir = r(:send, :sillymethod, r(:lit, "hello"), [r(:infix, :+, [r(:lit, 5), r(:lit, 10)]),
                                                   r(:send, :puts, :implicit, [r(:getvar, "hello")], nil)], block)
    ir.to_s.should.equal("\"hello\".sillymethod(5 + 10, puts(hello)) do |arg1, *rest|\n  avar\n  avar = 5\nend")
  end

  it "converts a simple method definition" do
    ir = r(:defmethod, r(:lit, 0), :amethod, r(:list, r(:getvar, "avar")), "")
    ir.to_s.should.equal("def amethod\n  avar\nend")
  end

  it "converts a simple method definition with arguments" do
    ir = r(:defmethod, r(:lit, 0), :amethod, r(:list, r(:getvar, "avar")), "arg1, *rest")
    ir.to_s.should.equal("def amethod(arg1, *rest)\n  avar\nend")
  end

  it "converts a simple method definition with a receiver" do
    ir = r(:defmethod, r(:getvar, :obj), :amethod, r(:list, r(:getvar, "avar")), "")
    ir.to_s.should.equal("def obj.amethod\n  avar\nend")
  end

  it "converts metaclass definitions" do
    block = r(:list, r(:getvar, "avar"), r(:aset, r(:getvar, "hash"), r(:getvar, "key"), r(:getvar, "value")))
    ir = r(:general_module, :metaclass, r(:nil), block, [r(:getvar, "x")])
    ir.to_s.should.equal("class << x\n  avar\n  hash[key] = value\nend")
  end

  it "converts normal class definitions without a superclass" do
    block = r(:list, r(:getvar, "avar"), r(:aset, r(:getvar, "hash"), r(:getvar, "key"), r(:getvar, "value")))
    ir = r(:general_module, :class, r(:getvar, :Silly), block, ["", ""])
    ir.to_s.should.equal("class Silly\n  avar\n  hash[key] = value\nend")
  end

  it "converts normal class definitions with a superclass and a module base" do
    block = r(:list, r(:getvar, "avar"), r(:aset, r(:getvar, "hash"), r(:getvar, "key"), r(:getvar, "value")))
    ir = r(:general_module, :class, r(:getvar, :Silly), block, ["Base::", " < Super"])
    ir.to_s.should.equal("class Base::Silly < Super\n  avar\n  hash[key] = value\nend")
  end

  it "converts a module definition" do
    block = r(:list, r(:getvar, "avar"), r(:aset, r(:getvar, "hash"), r(:getvar, "key"), r(:getvar, "value")))
    ir = r(:general_module, :module, r(:getvar, :Silly), block, [""])
    ir.to_s.should.equal("module Silly\n  avar\n  hash[key] = value\nend")
  end

  it "converts a module definition with a base module" do
    block = r(:list, r(:getvar, "avar"), r(:aset, r(:getvar, "hash"), r(:getvar, "key"), r(:getvar, "value")))
    ir = r(:general_module, :module, r(:getvar, :Silly), block, ["Base::"])
    ir.to_s.should.equal("module Base::Silly\n  avar\n  hash[key] = value\nend")
  end

  it "converts a simple if-else branch" do
    block1 = r(:list, r(:nil))
    block2 = r(:list, r(:lit, 2))
    predicate = r(:infix, :==, [r(:getvar, "x"), r(:lit, 10)])
    ir = r(:if, predicate, block1, block2)
    ir.to_s.should.equal("if x == 10\n  nil\nelse\n  2\nend")
  end

  it "converts a simple unless-else branch" do
    block1 = r(:list, r(:nil))
    block2 = r(:list, r(:lit, 2))
    predicate = r(:infix, :==, [r(:getvar, "x"), r(:lit, 10)])
    ir = r(:unless, predicate, block1, block2)
    ir.to_s.should.equal("unless x == 10\n  nil\nelse\n  2\nend")
  end

  it "converts a chained if-elsif-else branch" do
    block1 = r(:list, r(:nil))
    block2 = r(:list, r(:lit, 2))
    block3 = r(:list, r(:lit, true))
    predicate1 = r(:infix, :==, [r(:getvar, "x"), r(:lit, 10)])
    predicate2 = r(:infix, :==, [r(:getvar, "x"), r(:lit, 30)])
    ir = r(:if, predicate1, block1, r(:list, r(:if, predicate2, block2, block3)))
    ir.to_s.should.equal("if x == 10\n  nil\nelsif x == 30\n  2\nelse\n  true\nend")
  end
end