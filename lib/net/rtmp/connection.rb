require 'net/rtmp/packet'

module Net
class RTMP
class Connection
  HEADER_BYTE = "\x03"
  HANDSHAKE_LENGTH = 1536

  def initialize(socket)
    @socket = socket
    @packets = {}
  end

  def handshake
    @socket.write("\x03" + random_string(HANDSHAKE_LENGTH))
    shared = @socket.read(2 * HANDSHAKE_LENGTH + 1)[(HANDSHAKE_LENGTH + 1)..-1]
    @socket.write(shared)
  end

  def get_data
    header = Packet::Header.new
    header.inherit(@last_header) if @last_header
    header.parse(@socket)
    if packet = @packets[header.oid]
      packet.endow(header)
    else
      packet = @packets[header.oid] = Packet.new(header)
    end
    packet << @socket.read(packet.bytes_to_fetch)
    if packet.complete?
      @packets.delete(header.oid)
      yield packet
    end
  end

  def need_data?
    @packets.any?
  end

private

  def random_string(length)
    (0...length).map{ rand(256) }.pack('C*')
  end

end
end
end
