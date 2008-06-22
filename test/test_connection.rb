$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'net/rtmp/connection'
require 'test/unit'
require 'stringio'

class RTMPConnectionTest < Test::Unit::TestCase

  def test_should_read_contiguous_chunks_and_concatenate_them_yielding_complete_packets
    sample = %w[
      03 00 00 01
      00 01 05 14 00 00 00 00 02 00 07 63 6f 6e 6e 65
      63 74 00 3f f0 00 00 00 00 00 00 03 00 03 61 70
      70 02 00 16 73 61 6d 70 6c 65 5f 76 69 64 65 6f
      63 6f 6e 66 65 72 65 6e 63 65 00 08 66 6c 61 73
      68 56 65 72 02 00 0c 57 49 4e 20 37 2c 30 2c 31
      39 2c 30 00 06 73 77 66 55 72 6c 02 00 78 66 69
      6c 65 3a 2f 2f 5c 5c 77 6e 6d 69 68 65 72 72 65
      73 30 33 5c 63 24 5c 44 6f 63 75 6d 65 6e 74 73
      20 61 6e 64 20 53 65 74 c3 74 69 6e 67 73 5c 6d
      69 63 6b 2e 68 65 72 72 65 73 2e 4d 49 43 4b 44
      4f 4d 41 49 4e 5c 4d 79 20 44 6f 63 75 6d 65 6e
      74 73 5c 46 6c 61 73 68 20 50 72 6f 6a 65 63 74
      73 5c 56 69 64 65 6f 52 65 70 72 61 63 74 69 63
      69 6e 67 2e 73 77 66 00 05 74 63 55 72 6c 02 00
      2a 72 74 6d 70 3a 2f 2f 31 39 32 2e 31 36 38 2e
      32 2e 31 34 2f 73 61 6d 70 6c 65 5f 76 69 64 65
      6f 63 6f 6e 66 65 72 65 6e c3 63 65 00 00 09 00
    ].map{ |c| c.to_i(16) }.pack('C*')
    socket = MockSocket.new(sample)
    connection = Net::RTMP::Connection.new(socket)
    packets = []
    3.times do
      connection.get_data do |packet|
        packets << packet
      end
    end
    data = sample[12,128] + sample[141,128] + sample[270,5]
    assert_equal data, packets[0].body
  end

  def test_should_read_non_contiguous_chunks_of_same_length_and_concatenate_them_yielding_complete_packets
    data = [
      [ random_string(128), random_string(128), random_string(5) ],
      [ random_string(128), random_string(128), random_string(5) ]
    ]
    sample = "\x03\x00\x00\x01\x00\x01\x05\x14\x00\x00\x00\x00" +
             data[0][0] +
             "\xc3" +
             data[0][1] +
             "\xc4" +
             data[1][0] +
             "\xc3" +
             data[0][2] +
             "\xc4" +
             data[1][1] +
             "\xc4" +
             data[1][2]
    socket = MockSocket.new(sample)
    connection = Net::RTMP::Connection.new(socket)
    packets = []
    6.times do
      connection.get_data do |packet|
        packets << packet
      end
    end
    assert_equal [data[0].join, data[1].join], packets.map{ |p| p.body }
  end

  def test_should_send_header
    socket = MockSocket.new(random_string(1536 * 3))
    connection = Net::RTMP::Connection.new(socket)
    connection.handshake
    assert_match %r{\A\x03.{1536}\Z}m, socket.written[0]
  end

  def test_should_respond_to_handshake
    handshake_string = random_string(1536)
    socket = MockSocket.new("\x03" + random_string(1536) + handshake_string)
    connection = Net::RTMP::Connection.new(socket)
    connection.handshake
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
