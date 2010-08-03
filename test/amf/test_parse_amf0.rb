require File.expand_path("../../common", __FILE__)
require 'net/rtmp/amf'

class AMF0ParseTest < Test::Unit::TestCase

  def assert_parsed(expected, filename)
    path = File.expand_path("../data/amf0/#{filename}", __FILE__)
    amf = Net::RTMP::AMF.new(0)
    amf.parse(File.read(path))
    assert_equal [expected], amf.to_a
  end

  def test_number
    assert_parsed 123, "number"
  end

  def test_boolean_true
    assert_parsed true, "boolean_true"
  end

  def test_boolean_false
    assert_parsed true, "boolean_true"
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

  def test_null
    assert_parsed nil, "null"
  end

  def test_undefined
    assert_parsed nil, "undefined"
  end

  def test_reference
    data = {
      "obj1" => {"foo" => "bar"},
      "obj2" => {"foo" => "bar"}
    }
    assert_parsed data, "reference"
  end

  def test_nested_reference
    data = {
      "obj"  => {"foo" => "bar"},
      "obj2" => {"foo" => "bar"},
      "ary"  => ["a", "b", "c"],
      "nested" => {
        "ary" => ["a", "b", "c"],
        "obj" => {"foo" => "bar"}
      }
    }
    assert_parsed data, "reference_nested"
  end

  def test_ecma_array
    data = {
      "0"   => "foo",
      "bar" => "baz"
    }
    assert_parsed data, "ecma_array"
  end

  def test_strict_array
    data = ["foo", "bar", "baz"]
    assert_parsed data, "strict_array"
  end

  def test_date
    assert_parsed 1216717318745, "date"
  end
end
