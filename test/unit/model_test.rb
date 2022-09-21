# encoding: utf-8
require 'test_helper'

class ModelTest < ChordTestCase

  def test_order_find_with_nil_id_returns_nil
    assert_nil Chord::Order.find(nil)
  end

  def test_order_subscription_installment?
    assert Chord::Order.find('COMMONS-758805215').subscription_installment?
    assert !Chord::Order.find('COMMONS-454311249').subscription_installment?
  end

  def test_order_subscription_start?
    assert Chord::Order.find('COMMONS-301873119').subscription_start?
    assert !Chord::Order.find('COMMONS-758805215').subscription_start?
    assert !Chord::Order.find('COMMONS-244796031').subscription_start?
  end

  def test_order_uses_number_as_id
    o = Chord::Order.find('COMMONS-301873119')
    assert_equal 'COMMONS-301873119', o.id
    orders = Chord::Order.where('q[completed_at_gt]' => '2022-09-19')
    assert_equal 'COMMONS-', orders.first.id[0...8]
  end

  def test_order_expand!
    orders = Chord::Order.where('q[completed_at_gt]' => '2022-09-19')
    o = orders.first
    assert !o.attributes.include?('line_items')
    o.expand!
    assert o.attributes.include?('line_items')
  end
end
