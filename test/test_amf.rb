$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'net/rtmp/amf'
require 'test/unit'
require 'mocha'

class AMFTest < Test::Unit::TestCase

  def test_should_extract_elements_from_sample_1
    amf = Net::RTMP::AMF.new
    amf.parse(SAMPLE_1)
    expected = [
      "connect",
      1.0,
      {
        "capabilities" => 15.0,
        "videoFunction" => 1.0,
        "audioCodecs" => 1639.0,
        "app" =>
          "ondemand?_fcs_vhost=cp48184.edgefcs.net&auth=daEcIaKaQdfaicZcBa_aLa9dYbhdCaCc3d9-bizwQB-cCp-FnrDCqBnNDoGuwF&aifp=v001&slist=secure/6music/AMI_e6d01bf639fe37be3a42e423f9f38425_b00c73d2_6m_lamacq_thu",
        "videoCodecs" => 252.0,
        "swfUrl" => "http://www.bbc.co.uk/emp/player.swf?revision=3704",
        "pageUrl" => "http://www.bbc.co.uk/iplayerbeta/episode/b00c73fc",
        "tcUrl" =>
          "rtmp://84.53.177.140:1935/ondemand?_fcs_vhost=cp48184.edgefcs.net&auth=daEcIaKaQdfaicZcBa_aLa9dYbhdCaCc3d9-bizwQB-cCp-FnrDCqBnNDoGuwF&aifp=v001&slist=secure/6music/AMI_e6d01bf639fe37be3a42e423f9f38425_b00c73d2_6m_lamacq_thu",
        "fpad" => false,
        "flashVer" => "LNX 9,0,124,0"
      }
    ]
    assert_equal expected, amf.to_a
  end

  def test_should_extract_elements_from_sample_2
    amf = Net::RTMP::AMF.new
    amf.parse(SAMPLE_2)
    expected = ['_checkbw', 0.0, nil]
    assert_equal expected, amf.to_a
  end

  def self.to_bytes(array)
    array.map{ |b| b.to_i(16) }.pack('C*')
  end

  SAMPLE_1 = to_bytes(%w(
    02 00 07 63 6f 6e 6e 65   63 74 00 3f f0 00 00 00
    00 00 00 03 00 03 61 70   70 02 00 c5 6f 6e 64 65
    6d 61 6e 64 3f 5f 66 63   73 5f 76 68 6f 73 74 3d
    63 70 34 38 31 38 34 2e   65 64 67 65 66 63 73 2e
    6e 65 74 26 61 75 74 68   3d 64 61 45 63 49 61 4b
    61 51 64 66 61 69 63 5a   63 42 61 5f 61 4c 61 39
    64 59 62 68 64 43 61 43   63 33 64 39 2d 62 69 7a
    77 51 42 2d 63 43 70 2d   46 6e 72 44 43 71 42 6e
    4e 44 6f 47 75 77 46 26   61 69 66 70 3d 76 30 30
    31 26 73 6c 69 73 74 3d   73 65 63 75 72 65 2f 36
    6d 75 73 69 63 2f 41 4d   49 5f 65 36 64 30 31 62
    66 36 33 39 66 65 33 37   62 65 33 61 34 32 65 34
    32 33 66 39 66 33 38 34   32 35 5f 62 30 30 63 37
    33 64 32 5f 36 6d 5f 6c   61 6d 61 63 71 5f 74 68
    75 00 08 66 6c 61 73 68   56 65 72 02 00 0d 4c 4e
    58 20 39 2c 30 2c 31 32   34 2c 30 00 06 73 77 66
    55 72 6c 02 00 31 68 74   74 70 3a 2f 2f 77 77 77
    2e 62 62 63 2e 63 6f 2e   75 6b 2f 65 6d 70 2f 70
    6c 61 79 65 72 2e 73 77   66 3f 72 65 76 69 73 69
    6f 6e 3d 33 37 30 34 00   05 74 63 55 72 6c 02 00
    df 72 74 6d 70 3a 2f 2f   38 34 2e 35 33 2e 31 37
    37 2e 31 34 30 3a 31 39   33 35 2f 6f 6e 64 65 6d
    61 6e 64 3f 5f 66 63 73   5f 76 68 6f 73 74 3d 63
    70 34 38 31 38 34 2e 65   64 67 65 66 63 73 2e 6e
    65 74 26 61 75 74 68 3d   64 61 45 63 49 61 4b 61
    51 64 66 61 69 63 5a 63   42 61 5f 61 4c 61 39 64
    59 62 68 64 43 61 43 63   33 64 39 2d 62 69 7a 77
    51 42 2d 63 43 70 2d 46   6e 72 44 43 71 42 6e 4e
    44 6f 47 75 77 46 26 61   69 66 70 3d 76 30 30 31
    26 73 6c 69 73 74 3d 73   65 63 75 72 65 2f 36 6d
    75 73 69 63 2f 41 4d 49   5f 65 36 64 30 31 62 66
    36 33 39 66 65 33 37 62   65 33 61 34 32 65 34 32
    33 66 39 66 33 38 34 32   35 5f 62 30 30 63 37 33
    64 32 5f 36 6d 5f 6c 61   6d 61 63 71 5f 74 68 75
    00 04 66 70 61 64 01 00   00 0c 63 61 70 61 62 69
    6c 69 74 69 65 73 00 40   2e 00 00 00 00 00 00 00
    0b 61 75 64 69 6f 43 6f   64 65 63 73 00 40 99 9c
    00 00 00 00 00 00 0b 76   69 64 65 6f 43 6f 64 65
    63 73 00 40 6f 80 00 00   00 00 00 00 0d 76 69 64
    65 6f 46 75 6e 63 74 69   6f 6e 00 3f f0 00 00 00
    00 00 00 00 07 70 61 67   65 55 72 6c 02 00 31 68
    74 74 70 3a 2f 2f 77 77   77 2e 62 62 63 2e 63 6f
    2e 75 6b 2f 69 70 6c 61   79 65 72 62 65 74 61 2f
    65 70 69 73 6f 64 65 2f   62 30 30 63 37 33 66 63
    00 00 09
  ))
  
  SAMPLE_2 = to_bytes(%w(
    02 00 08 5f 63 68 65 63   6b 62 77 00 00 00 00 00
    00 00 00 00 05 
  ))

end
