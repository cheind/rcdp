#
# Project:: Ruby-Snippets
# 
# Author:: Christoph Heindl  (mailto:christoph.heindl@gmail.com)
# Homepage:: http://cheind.wordpress.com

require 'test/unit'
require 'ext/reverse_merge'

class TestHashReverseMerge < Test::Unit::TestCase
  def test_should_override_defaults
    opts = {:name=>'christoph', :age=>28, :language=>'ruby'}
    opts.reverse_merge!(:email=>'christoph.heindl@gmail.com', :name=>'user')
    assert_equal(opts[:name], 'christoph')
    assert_equal(opts[:email], 'christoph.heindl@gmail.com')
    assert_equal(opts[:age], 28)
  end
end