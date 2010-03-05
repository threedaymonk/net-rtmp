require 'net/rtmp/packet'
require 'net/rtmp/bytestream'
require 'stringio'

module Net
class RTMP
class AMF
  EndOfPacket = Class.new

  DECODE_DATA_TYPE = {
    0x00 => :number,
    0x01 => :boolean,
    0x02 => :string,
    0x03 => :object,
    0x04 => :movieclip,
    0x05 => :null,
    0x06 => :undefined,
    0x07 => :reference,
    0x08 => :ecma_array,
    0x09 => :object_end,
    0x0a => :strict_array,
    0x0b => :date,
    0x0c => :long_string,
    0x0d => :unsupported,
    0x0e => :record_set,
    0x0f => :xml_object,
    0x10 => :typed_object
  }
  ENCODE_DATA_TYPE = DECODE_DATA_TYPE.invert

  def initialize
    @elements = []
  end

  def parse(data)
    @elements = recursive_parse(Bytestream.new(StringIO.new(data)))
  end

  def to_a
    @elements
  end

private

  def recursive_parse(bytestream)
    elements = []
    until bytestream.eof? || (e = next_element(bytestream)) == EndOfPacket
      elements << e
    end
    elements
  end

  def next_element(bytestream)
    data_type = DECODE_DATA_TYPE[read_data_type(bytestream)]
    value = __send__("read_#{data_type}", bytestream)
    value
  end

  def read_data_type(bytestream)
    bytestream.read_uint8
  end

  def read_length_prefixed_data(bytestream)
    length = bytestream.read_uint16_be
    bytestream.read(length)
  end

  alias_method :read_string,      :read_length_prefixed_data
  alias_method :read_long_string, :read_length_prefixed_data

  def read_number(bytestream)
    bytestream.read_double_be
  end

  def read_boolean(bytestream)
    bytestream.read_uint8 != 0
  end

  def read_object(bytestream)
    hash = {}
    until (key = read_length_prefixed_data(bytestream)) == ''
      hash[key] = next_element(bytestream)
    end
    hash
  end

  def read_null(_)
    nil
  end

  def read_object_end(_)
    EndOfPacket
  end

end
end
end
