require File.expand_path("../common", __FILE__)
require 'net/rtmp/packet'

class RTMPPacketTest < Test::Unit::TestCase

  context "when receiving" do
    should "not be complete if all the data has not been received" do
      header = stub_everything(:body_length => 8)
      packet = Net::RTMP::Packet.new(header)
      packet << '1234' << '567'
      assert !packet.complete?
    end

    should "be complete when all data has been received" do
      header = stub_everything(:body_length => 8)
      packet = Net::RTMP::Packet.new(header)
      packet << '1234' << '5678'
      assert packet.complete?
    end

    should "return unfetched data remaining in 128 byte chunks" do
      header = stub_everything(:body_length => 129)
      packet = Net::RTMP::Packet.new(header)
      assert_equal 128, packet.bytes_to_fetch
      packet << ('x' * 128)
      assert_equal 1, packet.bytes_to_fetch
      packet << ('x')
      assert_equal 0, packet.bytes_to_fetch
    end

    should "endow header with own headers" do
      header = Net::RTMP::Packet::Header.new
      packet = Net::RTMP::Packet.new(header)
      new_header = mock
      new_header.expects(:inherit).with(header)
      packet.endow(new_header)
    end
  end

  context "when transmitting" do
    should "write data in 128-byte chunks with header" do
      data = random_string(128+128+7) # 0x107
      packet = Net::RTMP::Packet.new
      packet.oid          = 4
      packet.timestamp    = 0x000001
      packet.content_type = 0x14
      packet.stream_id    = 0x78563412
      packet.body         = data
      expected = [
        hex("04 00 00 01 00 01 07 14 12 34 56 78"), data[0,128],
        hex("C4"), data[128,128],
        hex("C4"), data[256,7]
      ].join
      output = ""
      packet.generate(StringIO.new(output))
      assert_equal expected, output
    end
  end
end
