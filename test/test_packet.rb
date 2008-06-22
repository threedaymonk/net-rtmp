$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'net/rtmp/packet'
require 'test/unit'
require 'stringio'
require 'mocha'

class RTMPPacketTest < Test::Unit::TestCase

  def test_should_not_be_complete
    header = stub(:body_length => 8)
    packet = Net::RTMP::Packet.new(header)
    packet << '1234' << '567'
    assert !packet.complete?
  end

  def test_should_be_complete_when_all_data_has_been_received
    header = stub(:body_length => 8)
    packet = Net::RTMP::Packet.new(header)
    packet << '1234' << '5678'
    assert packet.complete?
  end

  def test_should_return_unfetched_data_remaining_in_128_byte_chunks
    header = stub(:body_length => 129)
    packet = Net::RTMP::Packet.new(header)
    assert_equal 128, packet.bytes_to_fetch
    packet << ('x' * 128)
    assert_equal 1, packet.bytes_to_fetch
    packet << ('x')
    assert_equal 0, packet.bytes_to_fetch
  end

end

class RTMPPacketHeaderTest < Test::Unit::TestCase

  def test_should_get_all_data_from_12_byte_header
    data = [0b0010_1011, 0x12, 0x34, 0x56,
                   0x78, 0x9a, 0xbc, 0xde,
                   0x11, 0x22, 0x33, 0x44].pack('C*')
    header = Net::RTMP::Packet::Header.new
    header.parse(StringIO.new(data))
    assert_equal 0b10_1011,  header.oid
    assert_equal 0x123456,   header.timestamp
    assert_equal 0x789abc,   header.body_length
    assert_equal 0xde,       header.content_type
    assert_equal 0x44332211, header.stream_id
  end

  def test_should_get_object_id_and_time_stamp_and_length_and_content_type_from_8_byte_header
    data = [0b0110_1011, 0x12, 0x34, 0x56,
                   0x78, 0x9a, 0xbc, 0xde].pack('C*')
    header = Net::RTMP::Packet::Header.new
    header.parse(StringIO.new(data))
    assert_equal 0b10_1011,  header.oid
    assert_equal 0x123456,   header.timestamp
    assert_equal 0x789abc,   header.body_length
    assert_equal 0xde,       header.content_type
  end

  def test_should_get_object_id_and_time_stamp_from_4_byte_header
    data = [0b1010_1011, 0x12, 0x34, 0x56].pack('C*')
    header = Net::RTMP::Packet::Header.new
    header.parse(StringIO.new(data))
    assert_equal 0b10_1011,  header.oid
    assert_equal 0x123456,   header.timestamp
  end

  def test_should_get_object_id_from_1_byte_header
    data = [0b11010101].pack('C*')
    header = Net::RTMP::Packet::Header.new
    header.parse(StringIO.new(data))
    assert_equal 0b010101, header.oid
  end

  def test_should_be_128_bytes_long_by_default
    data = [0b11010101].pack('C*')
    header = Net::RTMP::Packet::Header.new
    header.parse(StringIO.new(data))
    assert_equal 128, header.body_length
  end

  def test_should_inherit_data_from_preceding_packet
    current = Net::RTMP::Packet::Header.new
    previous = stub(
      :oid          => 99,
      :timestamp    => 88,
      :body_length  => 77,
      :content_type => 66,
      :stream_id    => 55
    )
    current.inherit(previous)
    assert_equal 99, current.oid
    assert_equal 88, current.timestamp
    assert_equal 77, current.body_length
    assert_equal 66, current.content_type
    assert_equal 55, current.stream_id
  end

  def test_should_prefer_own_data_when_inheriting_data_from_preceding_packet
    data = [0b0010_1011, 0x12, 0x34, 0x56,
                   0x78, 0x9a, 0xbc, 0xde,
                   0x11, 0x22, 0x33, 0x44].pack('C*')
    header = Net::RTMP::Packet::Header.new
    header.parse(StringIO.new(data))
    previous = stub(
      :oid          => 99,
      :timestamp    => 88,
      :body_length  => 77,
      :content_type => 66,
      :stream_id    => 55
    )
    header.inherit(previous)
    assert_equal 0b10_1011,  header.oid
    assert_equal 0x123456,   header.timestamp
    assert_equal 0x789abc,   header.body_length
    assert_equal 0xde,       header.content_type
    assert_equal 0x44332211, header.stream_id
  end

end
