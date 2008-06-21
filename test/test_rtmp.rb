$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'net/rtmp'
require 'test/unit'
require 'stringio'
require 'mocha'

class RTMPTest < Test::Unit::TestCase

  def test_should_use_default_port
    TCPSocket.expects(:new).with('example.com', 1935).returns(mock)
    rtmp = Net::RTMP.new('rtmp://example.com/foo')
  end

  def test_should_use_supplied_port
    TCPSocket.expects(:new).with('example.com', 1234).returns(mock)
    rtmp = Net::RTMP.new('rtmp://example.com:1234/foo')
  end

end
