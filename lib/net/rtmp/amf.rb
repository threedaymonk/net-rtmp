require 'net/rtmp/packet'
require 'stringio'

module Net
class RTMP
class AMF

  EndOfPacket = Class.new

  DT_NUMBER       = 0x00
  DT_BOOLEAN      = 0x01
  DT_STRING       = 0x02
  DT_OBJECT       = 0x03
  DT_MOVIECLIP    = 0x04
  DT_NULL_VALUE   = 0x05
  DT_UNDEFINED    = 0x06
  DT_REFERENCE    = 0x07
  DT_ECMA_ARRAY   = 0x08
  DT_OBJECT_END   = 0x09
  DT_STRICT_ARRAY = 0x0a
  DT_DATE         = 0x0b
  DT_LONG_STRING  = 0x0c
  DT_UNSUPPORTED  = 0x0d
  DT_RECORD_SET   = 0x0e
  DT_XML_OBJECT   = 0x0f
  DT_TYPED_OBJECT = 0x10 

  def initialize
    @elements = []
  end

  def parse(data)
    @elements = recursive_parse(StringIO.new(data))
  end

  def to_a
    @elements
  end

private

  def recursive_parse(io)
    elements = []
    until io.eof? || (e = next_element(io)) == EndOfPacket
      elements << e
    end
    elements
  end

  def next_element(io)
    data_type = io.read(1).unpack('C')[0]
    case data_type
    when DT_NUMBER
      io.read(8).unpack('G')[0]
    when DT_BOOLEAN
      io.read(1).unpack('C')[0] != 0
    when DT_OBJECT
      hash = {}
      until (key = read_length_prefixed_data(io)) == ''
        hash[key] = next_element(io)
      end
      hash
    when DT_STRING, DT_LONG_STRING
      read_length_prefixed_data(io)
    when DT_OBJECT_END
      EndOfPacket
    when DT_NULL_VALUE
      nil
    else
      read_length_prefixed_data(io)
    end 
  end

  def read_length_prefixed_data(io)
    length = io.read(2).unpack('n')[0]
    io.read(length)
  end

end
end
end
