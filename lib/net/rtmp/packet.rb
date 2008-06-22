module Net
class RTMP
class Packet

  attr_reader :body
  attr_accessor :oid, :timestamp, :content_type, :stream_id

  def initialize(header)
    @header       = header
    @body_length  = header.body_length
    @oid          = header.oid
    @timestamp    = header.timestamp
    @content_type = header.content_type
    @stream_id    = header.stream_id
    @body = ''
  end

  def endow(header)
    header.inherit(@header)
  end

  def <<(data)
    @body << data
    self
  end

  def complete?
    bytes_to_fetch <= 0
  end

  def bytes_to_fetch
    [@body_length - @body.length, 128].min
  end
  
  class Header
    HEADER_LENGTHS = {
      0b00 => 12,
      0b01 =>  8,
      0b10 =>  4,
      0b11 =>  1
    }

    attr_accessor :oid, :timestamp, :body_length, :content_type, :stream_id

    def inherit(previous)
      @oid          ||= previous.oid
      @timestamp    ||= previous.timestamp
      @body_length  ||= previous.body_length
      @content_type ||= previous.content_type
      @stream_id    ||= previous.stream_id
    end

    def body_length
      @body_length || 128
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

    def generate
    end
  end
end
end
end
