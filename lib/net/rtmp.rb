require 'net/rtmp/connection'
require 'net/rtmp/constants'
require 'net/rtmp/packet'
require 'socket'
require 'uri'

module Net
  class RTMP
    def initialize(uri)
      @uri = URI.parse(uri)
      connect
    end

    def connect
      socket = TCPSocket.new(@uri.host, @uri.port || PORT)
      @connection = Connection.new(socket)
    end
  end
end

