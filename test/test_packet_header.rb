require File.expand_path("../common", __FILE__)
require 'net/rtmp/packet'

class RTMPPacketHeaderTest < Test::Unit::TestCase

  context "when decoding a header" do
    should "get all data from 12-byte header" do
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

    should "get object ID, time stamp, length, and content type from 8-byte header" do
      data = [0b0110_1011, 0x12, 0x34, 0x56,
                     0x78, 0x9a, 0xbc, 0xde].pack('C*')
      header = Net::RTMP::Packet::Header.new
      header.parse(StringIO.new(data))
      assert_equal 0b10_1011,  header.oid
      assert_equal 0x123456,   header.timestamp
      assert_equal 0x789abc,   header.body_length
      assert_equal 0xde,       header.content_type
    end

    should "get object ID and time stamp from 4-byte header" do
      data = [0b1010_1011, 0x12, 0x34, 0x56].pack('C*')
      header = Net::RTMP::Packet::Header.new
      header.parse(StringIO.new(data))
      assert_equal 0b10_1011,  header.oid
      assert_equal 0x123456,   header.timestamp
    end

    should "get object ID from 1-byte header" do
      data = [0b11010101].pack('C*')
      header = Net::RTMP::Packet::Header.new
      header.parse(StringIO.new(data))
      assert_equal 0b010101, header.oid
    end

    should "be 128 bytes long by default" do
      data = [0b11010101].pack('C*')
      header = Net::RTMP::Packet::Header.new
      header.parse(StringIO.new(data))
      assert_equal 128, header.body_length
    end

    should "inherit data from preceding packet" do
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

    should "prefer own data when inheriting data from preceding packet" do
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

  context "when generating a header" do
    should "generate 12-byte header" do
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

    should "generate 1-byte header" do
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

    should "produce original data via a round trip" do
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
end
