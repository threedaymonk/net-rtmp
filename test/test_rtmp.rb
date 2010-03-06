require File.expand_path("../common", __FILE__)
require 'net/rtmp'

class RTMPTest < Test::Unit::TestCase

  should "use port 1935 by default" do
    TCPSocket.expects(:new).with('example.com', 1935).returns(mock)
    Net::RTMP::Connection.stubs(:new)
    rtmp = Net::RTMP.new('rtmp://example.com/foo')
  end

  should "use supplied port" do
    TCPSocket.expects(:new).with('example.com', 1234).returns(mock)
    Net::RTMP::Connection.stubs(:new)
    rtmp = Net::RTMP.new('rtmp://example.com:1234/foo')
  end

  should "establish connection" do
    TCPSocket.stubs(:new).returns(socket = stub_everything)
    Net::RTMP::Connection.expects(:new).with(socket)
    rtmp = Net::RTMP.new('rtmp://example.com/foo')
  end
end
