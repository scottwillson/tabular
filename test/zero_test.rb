require "helper"

class ZeroTest < Test::Unit::TestCase
  include Tabular::Zero

  def test_zero
    assert is_zero?(0)
    assert is_zero?(0.0)
    assert is_zero?("0")
    assert is_zero?("0.0")
    assert is_zero?("00000.00000")

    assert !is_zero?(1)
    assert !is_zero?(-1)
    assert !is_zero?(0.1)
    assert !is_zero?("1")
    assert !is_zero?("ABC")
    assert !is_zero?(nil)
    assert !is_zero?("")
    assert !is_zero?(false)
    assert !is_zero?(true)
  end
end
