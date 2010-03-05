module Net
  class RTMP
    class Packet
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
          bytestream = Bytestream.new(io)
          first = bytestream.read_uint8
          header_length = HEADER_LENGTHS[first >> 6]
          @oid = first & 0b0011_1111
          if header_length >= 4
            @timestamp = bytestream.read_uint24_be
          end
          if header_length >= 8
            @body_length = bytestream.read_uint24_be
            @content_type = bytestream.read_uint8
          end
          if header_length == 12
            @stream_id = bytestream.read_uint32_le
          end
        end

        def generate(length=12)
          length_marker = HEADER_LENGTHS.invert[length] << 6
          raw = [length_marker | @oid].pack('C')
          if length == 12
            raw << [@timestamp].pack('N')[1,3]
            raw << [@body_length].pack('N')[1,3]
            raw << [@content_type].pack('C')
            raw << [@stream_id].pack('V')
          end
          raw
        end
      end
    end
  end
end
