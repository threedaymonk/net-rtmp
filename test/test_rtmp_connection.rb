$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'net/rtmp/connection'
require 'test/unit'
require 'stringio'

class RTMPConnectionTest < Test::Unit::TestCase

  def test_should_send_header
    socket = MockSocket.new(random_string(1536 * 3))
    connection = Net::RTMP::Connection.new(socket)
    assert_match %r{\A\x03.{1536}\Z}m, socket.written[0]
  end

  def test_should_respond_to_handshake
    handshake_string = random_string(1536)
    socket = MockSocket.new("\x03" + random_string(1536) + handshake_string)
    connection = Net::RTMP::Connection.new(socket)
    assert_equal handshake_string, socket.written[1]
  end

  def random_string(length)
    (0...length).map{ rand(256) }.pack('C*')
  end

  class MockSocket
    def initialize(buffer='')
      @buffer = StringIO.new(buffer)
      @written = []
    end

    def read(*args)
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
