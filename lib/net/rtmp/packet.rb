module Net
class RTMP
class Packet
  HEADER_LENGTHS = {
    0b00 => 12,
    0b01 =>  8,
    0b10 =>  4,
    0b11 =>  1
  }

  attr_reader :oid, :timestamp, :body_length, :content_type, :stream_id

  def initialize(io)
    parse(io)
  end

  def parse(io)
    byte = io.read(1).unpack('C')[0]
    header_length = HEADER_LENGTHS[byte >> 6] 
    @oid = byte & 0b0011_1111
    if header_length >= 4
      @timestamp = ("\x00" + io.read(3)).unpack('N')[0]
    end
    if header_length >= 8
      @body_length = ("\x00" + io.read(3)).unpack('N')[0]
      @content_type = io.read(1).unpack('C')[0]
    end
    if header_length == 12
      @stream_id = io.read(4).unpack('V')[0]
    end
  end

end
end
end
