#!/usr/bin/ruby

require 'minitest/autorun'
require_relative '../lib/configfile_reader'

# MiniTest for ConfigFileReader Class
class ConfigFileReaderTest < Minitest::Test
  def test_read
    data = ConfigFileReader.read('tests/files/example-01.yaml')
    assert_equal nil, data[:global]
    assert_equal 1, data[:cases].size
  end
end
