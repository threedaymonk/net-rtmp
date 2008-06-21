module Net
class RTMP
  PORT = 1935

  module SharedObject
    CONNECT          = 0x01
    DISCONNECT       = 0x02
    SET_ATTRIBUTE    = 0x03
    UPDATE_DATA      = 0x04 
    UPDATE_ATTRIBUTE = 0x05
    SEND_MESSAGE     = 0x06
    STATUS           = 0x07
    CLEAR_DATA       = 0x08
    DELETE_DATA      = 0x09
    DELETE_ATTRIBUTE = 0x0a
    INITIAL_DATA     = 0x0b
  end
end
end
