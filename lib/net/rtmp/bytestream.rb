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

      def read_uint16_be
        read_and_unpack(2, 'n')
      end

      def read_double_be
        read_and_unpack(8, 'G')
      end

    private
      def read_and_unpack(length, specifier)
        read(length).unpack(specifier)[0]
      end

      end
    end
  end
