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
end
