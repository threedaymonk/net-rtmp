require 'net/rtmp/packet'
require 'stringio'

module Net
class RTMP
class AMF

  EndOfPacket = Class.new

  DATA_TYPES = {
    0x00 => :number,
    0x01 => :boolean,
    0x02 => :string,
    0x03 => :object,
    0x04 => :movieclip,
    0x05 => :null_value,
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
    data_type = DATA_TYPES[read_data_type(io)]
    value = __send__("read_#{data_type}", io)
    value
  end

  def read_data_type(io)
    io.read(1).unpack('C')[0]
  end

  def read_length_prefixed_data(io)
    length = io.read(2).unpack('n')[0]
    io.read(length)
  end

  alias_method :read_string,      :read_length_prefixed_data
  alias_method :read_long_string, :read_length_prefixed_data

  def read_number(io)
    io.read(8).unpack('G')[0]
  end

  def read_boolean(io)
    io.read(1).unpack('C')[0] != 0
  end

  def read_object(io)
    hash = {}
    until (key = read_length_prefixed_data(io)) == ''
      hash[key] = next_element(io)
    end
    hash
  end

  def read_null_value(io)
    nil
  end

  def read_object_end(io)
    EndOfPacket
  end

end
end
end
