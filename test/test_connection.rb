$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'net/rtmp/connection'
require 'test/unit'
require 'stringio'
require 'mocha'

class RTMPConnectionTest < Test::Unit::TestCase

  def test_should_concatenate_contiguous_chunks_and_yield_complete_packets
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

  def test_should_inherit_length_via_oid_even_if_oid_is_recycled
    sample = %w[
      42 00 00 00  00 00 0a 04
      00 03 00 00  00 00 00 00
      17 70
      43 00 00 00  00 00 01 04
      99
      c2 00 03 00  00 00 00 00
      00 13  88 00 00 00
    ].map{ |c| c.to_i(16) }.pack('C*') + "." * 1000
    socket = MockSocket.new(sample)
    connection = Net::RTMP::Connection.new(socket)
    packets = []
    3.times do
      connection.get_data do |packet|
        packets << packet
      end
    end
    assert_equal 0x0a, packets[0].body.length
    assert_equal 0x0a, packets[2].body.length
  end

  def test_should_concatenate_non_contiguous_chunks_and_yield_complete_packets
    data = [
      [ random_string(128), random_string(128), random_string(5) ],
      [ random_string(128), random_string(7) ]
    ]
    sample = "\x03\x00\x00\x01\x00\x01\x05\x14\x00\x00\x00\x00" +
             data[0][0] +
             "\x44\x00\x00\x01\x00\x00\x87\x14" +
             data[1][0] +
             "\xc3" +
             data[0][1] +
             "\xc4" +
             data[1][1] +
             "\xc3" +
             data[0][2]
    socket = MockSocket.new(sample)
    connection = Net::RTMP::Connection.new(socket)
    packets = []
    5.times do
      connection.get_data do |packet|
        packets << packet
      end
    end
    assert_equal [data[1].join, data[0].join], packets.map{ |p| p.body }
  end

  def test_should_have_complete_headers_in_yielded_packet
    data = [
      [ random_string(128), random_string(128), random_string(5) ],
      [ random_string(128), random_string(7) ]
    ]
    sample = "\x03\x00\x00\x01\x00\x01\x05\x14\x12\x34\x56\x78" +
             data[0][0] +
             "\x44\x00\x00\x01\x00\x00\x87\x14" +
             data[1][0] +
             "\xc3" +
             data[0][1] +
             "\xc4" +
             data[1][1] +
             "\xc3" +
             data[0][2]
    socket = MockSocket.new(sample)
    connection = Net::RTMP::Connection.new(socket)
    packets = []
    5.times do
      connection.get_data do |packet|
        packets << packet
      end
    end
    packet = packets[1]
    assert_equal 0x000001,   packet.timestamp
    assert_equal 0x14,       packet.content_type
    assert_equal 0x78563412, packet.stream_id
  end

  def test_should_need_data_when_packets_are_incomplete
    data = [
      [ random_string(128), random_string(128), random_string(5) ],
      [ random_string(128), random_string(7) ]
    ]
    sample = "\x03\x00\x00\x01\x00\x01\x05\x14\x12\x34\x56\x78" +
             random_string(128)
    socket = MockSocket.new(sample)
    connection = Net::RTMP::Connection.new(socket)
    connection.get_data{}
    assert connection.need_data?
  end

  def test_should_get_all_outstanding_packets
    data = [
      [ random_string(128), random_string(128), random_string(5) ],
      [ random_string(128), random_string(7) ]
    ]
    sample = "\x03\x00\x00\x01\x00\x01\x05\x14\x12\x34\x56\x78" +
             data[0][0] +
             "\x44\x00\x00\x01\x00\x00\x87\x14" +
             data[1][0] +
             "\xc3" +
             data[0][1] +
             "\xc4" +
             data[1][1] +
             "\xc3" +
             data[0][2]
    socket = MockSocket.new(sample)
    connection = Net::RTMP::Connection.new(socket)
    packets = []
    connection.fetch do |packet|
      packets << packet
    end
    assert_equal 2, packets.length
  end

  def test_should_send_packets
    data = "x" * (128+128+7)
    packet = Net::RTMP::Packet.new
    packet.oid          = 4
    packet.timestamp    = 0x000001
    packet.content_type = 0x14
    packet.stream_id    = 0x78563412
    packet.body         = data

    output = ""
    connection = Net::RTMP::Connection.new(StringIO.new(output))
    connection.send(packet)
    expected = [
      "\x04\x00\x00\x01\x00\x01\x07\x14\x12\x34\x56\x78", data[0,128],
      "\xC4", data[128,128],
      "\xC4", data[256,7]
    ].join
    assert_equal expected, output
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

  def test_should_raise_exception_when_no_more_data_is_available
    socket = StringIO.new
    connection = Net::RTMP::Connection.new(socket)
    assert_raises Net::RTMP::NoMoreData do
      connection.get_data{}
    end
  end

  def test_should_raise_exception_when_fewer_bytes_are_available_than_requested
    sample = "\x03\x00\x00\x01\x00\x01\x05\x14\x00\x00"
    socket = StringIO.new(sample)
    connection = Net::RTMP::Connection.new(socket)
    assert_raises Net::RTMP::NoMoreData do
      connection.get_data{}
    end
  end

private

  def random_string(length)
    (0...length).map{ rand(256) }.pack('C*')
  end

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
