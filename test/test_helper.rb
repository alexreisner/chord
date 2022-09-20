# encoding: utf-8
require 'rubygems'
require 'test/unit'
require 'chord'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

#require 'yaml'
#configs = YAML.load_file('test/database.yml')

class ChordTestCase < Test::Unit::TestCase
  self.test_order = :random

  def setup
    super
    # TODO: config
  end
end
