require './dbg'
module Test
  class Foo
    def m1
      m2
    end

    def m2
      m3
    end

    def m3
      tr = true
      ni = nil
      string = "123"
      fixnum = 123
      ary = [1, 2, 3]
      hash = {butts: "lol"}
      DBG.breakpoint
    end
  end
end

Test::Foo.new.m1
