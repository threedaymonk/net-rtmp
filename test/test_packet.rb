$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'net/rtmp/packet'
require 'test/unit'
require 'stringio'

class RTMPPacketTest < Test::Unit::TestCase

  def test_should_get_all_data_from_12_byte_header
    data = [0b0010_1011, 0x12, 0x34, 0x56,
                   0x78, 0x9a, 0xbc, 0xde,
                   0x11, 0x22, 0x33, 0x44].pack('C*')
    packet = Net::RTMP::Packet.new(StringIO.new(data))
    assert_equal 0b10_1011,  packet.oid
    assert_equal 0x123456,   packet.timestamp
    assert_equal 0x789abc,   packet.body_length
    assert_equal 0xde,       packet.content_type
    assert_equal 0x44332211, packet.stream_id
  end

  def test_should_get_object_id_and_time_stamp_and_length_and_content_type_from_8_byte_header
    data = [0b0110_1011, 0x12, 0x34, 0x56,
                   0x78, 0x9a, 0xbc, 0xde].pack('C*')
    packet = Net::RTMP::Packet.new(StringIO.new(data))
    assert_equal 0b10_1011,  packet.oid
    assert_equal 0x123456,   packet.timestamp
    assert_equal 0x789abc,   packet.body_length
    assert_equal 0xde,       packet.content_type
  end

  def test_should_get_object_id_and_time_stamp_from_4_byte_header
    data = [0b1010_1011, 0x12, 0x34, 0x56].pack('C*')
    packet = Net::RTMP::Packet.new(StringIO.new(data))
    assert_equal 0b10_1011,  packet.oid
    assert_equal 0x123456,   packet.timestamp
  end

  def test_should_get_object_id_from_1_byte_header
    data = [0b11010101].pack('C*')
    packet = Net::RTMP::Packet.new(StringIO.new(data))
    assert_equal 0b010101, packet.oid
  end

end
