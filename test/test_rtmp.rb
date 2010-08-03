require File.expand_path("../common", __FILE__)
require 'net/rtmp'

class RTMPTest < Test::Unit::TestCase

  def test_should_use_port_1935_by_default_do
    TCPSocket.expects(:new).with('example.com', 1935).returns(mock)
    Net::RTMP::Connection.stubs(:new)
    rtmp = Net::RTMP.new('rtmp://example.com/foo')
  end

  def test_should_use_supplied_port_do
    TCPSocket.expects(:new).with('example.com', 1234).returns(mock)
    Net::RTMP::Connection.stubs(:new)
    rtmp = Net::RTMP.new('rtmp://example.com:1234/foo')
  end

  def test_should_establish_connection_do
    TCPSocket.stubs(:new).returns(socket = stub_everything)
    Net::RTMP::Connection.expects(:new).with(socket)
    rtmp = Net::RTMP.new('rtmp://example.com/foo')
  end
end
