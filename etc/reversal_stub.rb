class ApplicationController
  def self.before_filter(*args)
  end
end

class ActionView
  module Helpers
    module JavaScriptHelper
    end
  end
end

module ActiveRecord
  class Base
    def self.belongs_to(other)
    end
    def self.validates(*args)
    end
  end
end

if ENV['UNRUBBY_STUBS']
  class Stub
    def self.method_missing(sym, *args)
      return Stub.new
    end
  end

  class Object
    def self.const_missing(const)
      Stub
    end
  end
end
