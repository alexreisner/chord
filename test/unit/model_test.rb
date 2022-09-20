# encoding: utf-8
require 'test_helper'

class ModelTest < ChordTestCase

  def test_find_order_with_nil_id_returns_nil
    assert_nil Chord::Order.find(nil)
  end
end
