require 'spec_helper'

describe "Really Large Decompilations" do
  before do
    @complex_nesting = CompiledDecompilationTestCase.new <<CLASS, <<RESULT
module Hello
  include SomeModule
  class World < Universe
    attr_accessor :name
    self.attr_writer :moons
    def initialize(some_thing, silly_arg = some_thing.to_s, *args)
      super
      @name = some_thing.to_s
    end

    def self.has_moon(size = MoonSizes::TINY)
      @@moons = []
      @@moons << Universe::Stuff::Moon.new(size)
      @@moons
    end

    def orbit!(optional_arg = 10, required_arg, &blk)
      @moons.each do |moon|
        if moon.spherical(:not_cube => true)
          moon.rotate
        else
          moon.cubify
        end
        moon.revolve! :twice
        class << moon
          def crash_into(other_planet)
            other_planet.go_boom!
          end
        end
        yield
      end
    end
  end
end
CLASS
module Hello
  include(SomeModule)
  class World < Universe
    attr_accessor(:name)
    self.attr_writer(:moons)
    def initialize(some_thing, silly_arg = some_thing.to_s, *args)
      super
      @name = some_thing.to_s
    end
    def self.has_moon(size = MoonSizes::TINY)
      @@moons = []
      @@moons << Universe::Stuff::Moon.new(size)
      @@moons
    end
    def orbit!(optional_arg = 10, required_arg, &blk)
      @moons.each do |moon|
        if moon.spherical({:not_cube => true})
          moon.rotate
        else
          moon.cubify
        end
        moon.revolve!(:twice)
        class << moon
          def crash_into(other_planet)
            other_planet.go_boom!
          end
        end
        yield
      end
    end
  end
end
RESULT
  end
  
  it "decompiles a complex nesting of modules, classes, definitions, and blocks" do
    @complex_nesting.assert_correct
  end
end