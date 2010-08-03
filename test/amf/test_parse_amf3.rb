require File.expand_path("../../common", __FILE__)
require 'net/rtmp/amf'

class AMF0ParseTest < Test::Unit::TestCase

  def assert_parsed(expected, filename)
    path = File.expand_path("../data/amf3/#{filename}", __FILE__)
    amf = Net::RTMP::AMF.new(3)
    amf.parse(File.read(path))
    case expected
    when Float
      assert_in_delta [expected], amf.to_a, 0.001
    else
      assert_equal [expected], amf.to_a
    end
  end

  def test_number
    assert_parsed 123.45, "number"
  end

  def test_boolean_true
    assert_parsed true, "true"
  end

  def test_boolean_false
    assert_parsed true, "true"
  end

  def test_string
    assert_parsed "foo", "string"
  end

  def test_object
    data = { "foo" => "bar" }
    assert_parsed data, "object"
  end

  def test_object_2
    data = {
      "array" => ["foo", "bar"],
      "hash"  => {"foo" => "bar"}
    }
    assert_parsed data, "object2"
  end

  def test_null_object
    data = {}
    assert_parsed data, "null_object"
  end

  def test_array
    data = ["foo", "bar"]
    assert_parsed data, "array"
  end

  def test_null
    assert_parsed nil, "null"
  end

  def test_undefined
    assert_parsed nil, "undefined"
  end

  def test_date
    # DateTime->new(
    #   year   => 2009,
    #   month  => 10,
    #   day    => 22,
    #   hour   => 03,
    #   minute => 34,
    #   second => 56
    # )
    flunk
  end

  def test_byte_array
    data = [10, 11, 1, 7, 102, 111, 111, 6, 7, 98, 97, 114, 1].pack("C*")
    assert_parsed data, "byte_array"
  end
end
