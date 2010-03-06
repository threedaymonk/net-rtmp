require "net/rtmp/bytestream"

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
          header_type, @oid = bytestream.read_bitfield(2, 6)
          header_length = HEADER_LENGTHS[header_type]
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

        def generate(io, length=12)
          bytestream = Bytestream.new(io)
          length_marker = HEADER_LENGTHS.invert[length]
          bytestream.write_bitfield([length_marker, 2], [oid, 6])
          if length == 12
            bytestream.write_uint24_be @timestamp
            bytestream.write_uint24_be @body_length
            bytestream.write_uint8     @content_type
            bytestream.write_uint32_le @stream_id
          end
        end
      end
    end
  end
end
