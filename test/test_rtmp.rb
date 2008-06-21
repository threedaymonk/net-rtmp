$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'net/rtmp'
require 'test/unit'
require 'stringio'
require 'mocha'

class RTMPTest < Test::Unit::TestCase

  def test_should_use_default_port
    TCPSocket.expects(:new).with('example.com', 1935).returns(mock)
    Net::RTMP::Connection.stubs(:new)
    rtmp = Net::RTMP.new('rtmp://example.com/foo')
  end

  def test_should_use_supplied_port
    TCPSocket.expects(:new).with('example.com', 1234).returns(mock)
    Net::RTMP::Connection.stubs(:new)
    rtmp = Net::RTMP.new('rtmp://example.com:1234/foo')
  end

  def test_should_establish_connection
    TCPSocket.stubs(:new).returns(socket = stub_everything)
    Net::RTMP::Connection.expects(:new).with(socket)
    rtmp = Net::RTMP.new('rtmp://example.com/foo')
  end

end
