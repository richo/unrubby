require 'pp'

module Reversal
  class BugReport
    attr_reader :iseq
    def initialize(iseq)
      @iseq = iseq
    end

    def header(s)
      puts s
      puts "-" * s.length
    end

    def dump
      header "iseq"
      pp iseq.to_a

      header "features"
      pp $LOADED_FEATURES.to_a

      header "platform"
      pp interesting_platform_details
    end

    def interesting_platform_details
      Hash[%w|MAJOR MINOR TEENY PATCHLEVEL
                  configure_args build target|.map do |i|
        [i, RbConfig::CONFIG[i]]
      end]
    end
  end
end
