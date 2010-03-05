module Net
  class RTMP
    PORT = 1935

    SHARED_OBJECTS = {
      :connect          => 0x01,
      :disconnect       => 0x02,
      :set_attribute    => 0x03,
      :update_data      => 0x04,
      :update_attribute => 0x05,
      :send_message     => 0x06,
      :status           => 0x07,
      :clear_data       => 0x08,
      :delete_data      => 0x09,
      :delete_attribute => 0x0a,
      :initial_data     => 0x0b
    }

    DATATYPES = {
      :chunk_size         => 0x01,
      :bytes_read         => 0x03,
      :ping               => 0x04,
      :server_bw          => 0x05,
      :client_bw          => 0x06,
      :audio_data         => 0x08,
      :video_data         => 0x09,
      :flex_stream        => 0x0f,
      :flex_shared_object => 0x10,
      :flex_message       => 0x11,
      :notify             => 0x12,
      :shared_object      => 0x13,
      :invoke             => 0x14,
      :flv_data           => 0x16
    }
  end
end
