require 'net/rtmp/packet/header'

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

end
end
end
