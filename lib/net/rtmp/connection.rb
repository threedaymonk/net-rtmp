module Net
class RTMP
class Connection
  HEADER_BYTE = "\x03"
  HANDSHAKE_LENGTH = 1536

  def initialize(socket)
    @socket = socket
    handshake
  end

  def handshake
    @socket.write("\x03" + random_string(HANDSHAKE_LENGTH))
    shared = @socket.read(2 * HANDSHAKE_LENGTH + 1)[(HANDSHAKE_LENGTH + 1)..-1]
    @socket.write(shared)
  end

private

  def random_string(length)
    (0...length).map{ rand(256) }.pack('C*')
  end

end
end
end
