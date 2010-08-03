require "forwardable"

module Net
  class RTMP
    class Bytestream
      extend Forwardable

      def_delegators :@io, :eof?, :read, :write

      def initialize(io)
        @io = io
      end

      def read_uint8
        read_and_unpack(1, 'C')
      end

      def write_uint8(value)
        write [value].pack('C')
      end

      def read_uint16_be
        read_and_unpack(2, 'n')
      end

      def write_uint16_be(value)
        [value].pack('n')
      end

      def read_uint24_be
        ("\x00" + read(3)).unpack('N')[0]
      end

      def write_uint24_be(value)
        write [value].pack('N')[1,3]
      end

      def read_uint32_be
        read_and_unpack(4, 'N')
      end

      def read_uint32_le
        read_and_unpack(4, 'V')
      end

      def write_uint32_be(value)
        write [value].pack('N')
      end

      def write_uint32_le(value)
        write [value].pack('V')
      end

      def read_double_be
        read_and_unpack(8, 'G')
      end

      def write_double_be
        write [value].pack('G')
      end

      def read_bitfield(*widths)
        byte = read_uint8
        shifts_and_masks(widths).map{ |shift, mask|
          (byte >> shift) & mask
        }
      end

      def write_bitfield(*values_and_widths)
        sm = shifts_and_masks(values_and_widths.map{ |_,w| w })
        write_uint8 values_and_widths.zip(sm).inject(0){ |byte, ((value, width), (shift, mask))|
          byte | ((value & mask) << shift)
        }
      end

    private
      def read_and_unpack(length, specifier)
        read(length).unpack(specifier)[0]
      end

      def shifts_and_masks(bit_widths)
        (0 ... bit_widths.length).map{ |i| [
          bit_widths[i+1 .. -1].inject(0){ |a,e| a + e },
          0b1111_1111 >> (8 - bit_widths[i])
        ]}
      end

    end
  end
end
