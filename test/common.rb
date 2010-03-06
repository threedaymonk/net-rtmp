$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require "test/unit"
require "shoulda"
require "mocha"
require "stringio"

class Test::Unit::TestCase
  module SharedMethods
    def hex(s)
      s.scan(/[0-9a-f]{2}/i).map{ |c| c.to_i(16) }.pack('C*')
    end

    def random_string(length)
      (0...length).map{ rand(256) }.pack('C*')
    end
  end

  include SharedMethods
  extend SharedMethods

  class MockSocket
    def initialize(buffer='')
      @buffer = StringIO.new(buffer)
      @written = []
    end

    def read(*args)
      #p([:read] + args)
      @buffer.read(*args)
    end

    def write(data)
      @written << data
    end

    def written
      @written
    end
  end
end
