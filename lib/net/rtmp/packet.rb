require 'net/rtmp/packet/header'

module Net
class RTMP
class Packet

  attr_accessor :body, :oid, :timestamp, :content_type, :stream_id

  def initialize(header=nil)
    parse_header(header) if header
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

  def generate
    bytes_sent = 0
    header = build_header
    while bytes_sent < @body.length
      bytes_to_send = [@body.length - bytes_sent, 128].min
      header_length =  bytes_sent == 0 ? 12 : 1
      yield(header.generate(header_length) + body[bytes_sent, bytes_to_send])
      bytes_sent += bytes_to_send
    end
  end

  def parse_header(header)
    @header       = header
    @body_length  = header.body_length
    @oid          = header.oid
    @timestamp    = header.timestamp
    @content_type = header.content_type
    @stream_id    = header.stream_id
  end

  def build_header
    header = Header.new
    header.body_length  = @body.length
    header.oid          = @oid
    header.timestamp    = @timestamp
    header.content_type = @content_type
    header.stream_id    = @stream_id
    header
  end

end
end
end
