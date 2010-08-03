require File.expand_path("../common", __FILE__)
require 'net/rtmp/packet'

class RTMPPacketHeaderDecodingTest < Test::Unit::TestCase

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

  def test_should_get_object_ID_and_time_stamp_and_length_and_and_content_type_from_8_byte_header
    data = [0b0110_1011, 0x12, 0x34, 0x56,
                   0x78, 0x9a, 0xbc, 0xde].pack('C*')
    header = Net::RTMP::Packet::Header.new
    header.parse(StringIO.new(data))
    assert_equal 0b10_1011,  header.oid
    assert_equal 0x123456,   header.timestamp
    assert_equal 0x789abc,   header.body_length
    assert_equal 0xde,       header.content_type
  end

  def test_should_get_object_ID_and_time_stamp_from_4_byte_header
    data = [0b1010_1011, 0x12, 0x34, 0x56].pack('C*')
    header = Net::RTMP::Packet::Header.new
    header.parse(StringIO.new(data))
    assert_equal 0b10_1011,  header.oid
    assert_equal 0x123456,   header.timestamp
  end

  def test_should_get_object_ID_from_1_byte_header
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

class RTMPPacketHeaderEncodingTest < Test::Unit::TestCase

  def test_should_generate_12_byte_header
    header = Net::RTMP::Packet::Header.new
    header.oid          = 0x4
    header.timestamp    = 0x01
    header.body_length  = 0x1234
    header.content_type = 0x14
    header.stream_id    = 0x78563412
    output = ""
    header.generate(StringIO.new(output))
    assert_equal hex("04 00 00 01 00 12 34 14 12 34 56 78"), output
  end

  def test_should_generate_1_byte_header
    header = Net::RTMP::Packet::Header.new
    header.oid          = 0x4
    header.timestamp    = 0x01
    header.body_length  = 0x1234
    header.content_type = 0x14
    header.stream_id    = 0x78563412
    output = ""
    header.generate(StringIO.new(output), 1)
    assert_equal hex("c4"), output
  end

  def test_should_produce_original_data_via_a_round_trip
    data = [0b0010_1011, 0x12, 0x34, 0x56,
                   0x78, 0x9a, 0xbc, 0xde,
                   0x11, 0x22, 0x33, 0x44].pack('C*')
    header = Net::RTMP::Packet::Header.new
    header.parse(StringIO.new(data))
    output = ""
    header.generate(StringIO.new(output))
    assert_equal data, output
  end
end
