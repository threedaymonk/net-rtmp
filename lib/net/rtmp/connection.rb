require 'net/rtmp/packet'
require 'net/rtmp/errors'

module Net
  class RTMP
    class Connection
      HEADER_BYTE = "\x03"
      HANDSHAKE_LENGTH = 1536

      def initialize(socket)
        @socket = WrappedSocket.new(socket)
        @packets = {}
        @headers = {}
      end

      def handshake
        @socket.write("\x03" + random_string(HANDSHAKE_LENGTH))
        shared = @socket.read(2 * HANDSHAKE_LENGTH + 1)[(HANDSHAKE_LENGTH + 1)..-1]
        @socket.write(shared)
      end

      def get_data
        header = Packet::Header.new
        header.parse(@socket)
        if packet = @packets[header.oid]
          packet.endow(header)
        else
          if previous_header = @headers[header.oid]
            header.inherit(previous_header)
          end
          packet = @packets[header.oid] = Packet.new(header)
        end
        @headers[header.oid] = header
        packet << @socket.read(packet.bytes_to_fetch)
        if packet.complete?
          @packets.delete(header.oid)
          yield packet
        end
      end

      def need_data?
        @packets.any?
      end

      def fetch(&blk)
        get_data(&blk)
        while need_data?
          get_data(&blk)
        end
      end

      def send(packet)
        packet.generate do |chunk|
          @socket.write(chunk)
        end
      end

    private
      def random_string(length)
        (0...length).map{ rand(256) }.pack('C*')
      end

      class WrappedSocket
        def initialize(socket)
          @socket = socket
        end

        def read(length=nil)
          if length
            data = @socket.read(length)
            raise NoMoreData if data.nil?
            return data
          else
            return @socket.read
          end
        end

        def write(data)
          @socket.write(data)
        end
      end

    end
  end
end
