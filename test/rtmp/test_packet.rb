require File.expand_path("../../common", __FILE__)
require 'net/rtmp/packet'

class RTMPPacketReceivingTest < Test::Unit::TestCase

  def test_should_not_be_complete_if_all_the_data_has_not_been_received
    header = stub_everything(:body_length => 8)
    packet = Net::RTMP::Packet.new(header)
    packet << '1234' << '567'
    assert !packet.complete?
  end

  def test_should_be_complete_when_all_data_has_been_received
    header = stub_everything(:body_length => 8)
    packet = Net::RTMP::Packet.new(header)
    packet << '1234' << '5678'
    assert packet.complete?
  end

  def test_should_return_unfetched_data_remaining_in_128_byte_chunks
    header = stub_everything(:body_length => 129)
    packet = Net::RTMP::Packet.new(header)
    assert_equal 128, packet.bytes_to_fetch
    packet << ('x' * 128)
    assert_equal 1, packet.bytes_to_fetch
    packet << ('x')
    assert_equal 0, packet.bytes_to_fetch
  end

  def test_should_endow_header_with_own_headers
    header = Net::RTMP::Packet::Header.new
    packet = Net::RTMP::Packet.new(header)
    new_header = mock
    new_header.expects(:inherit).with(header)
    packet.endow(new_header)
  end
end

class RTMPPacketTransmittingTest < Test::Unit::TestCase

  def test_should_write_data_in_128_byte_chunks_with_header
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
