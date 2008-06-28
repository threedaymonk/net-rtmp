%w[ connection constants packet amf errors ].each do |m|
  require "net/rtmp/#{m}"
end
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

