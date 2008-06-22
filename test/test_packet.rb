$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'net/rtmp/packet'
require 'test/unit'
require 'stringio'
require 'mocha'

class RTMPPacketReceptionTest < Test::Unit::TestCase

  def test_should_not_be_complete
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
