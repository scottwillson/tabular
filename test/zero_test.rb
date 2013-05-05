require "helper"

class ZeroTest < Test::Unit::TestCase
  def test_zero
    assert 0.zero?
    assert (0.0).zero?
    assert "0".zero?
    assert "0.0".zero?
    assert "00000.00000".zero?

    assert !(1.zero?)
    assert !(-1.zero?)
    assert !((0.1).zero?)
    assert !("1".zero?)
    assert !("ABC".zero?)
    assert !(nil.zero?)
    assert !("".zero?)
    assert !(false.zero?)
    assert !(true.zero?)
  end
end
