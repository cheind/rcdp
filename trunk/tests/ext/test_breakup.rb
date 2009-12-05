#
# Project:: Ruby-Snippets
# 
# Author:: Christoph Heindl  (mailto:christoph.heindl@gmail.com)
# Homepage:: http://cheind.wordpress.com
#

require 'test/unit'
require 'ext/breakup.rb'

class TestArrayBreakup < Test::Unit::TestCase
  def test_should_breakup_correctly
    assert_equal(nil, [].breakup)
    assert_equal(1, [1].breakup)
    assert_equal([1,2], [1,2].breakup)
    a = [1,2]
    assert_not_same(a, a.breakup)
  end
end