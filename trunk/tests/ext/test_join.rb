#
# Project:: Ruby-Snippets
# 
# Author:: Christoph Heindl  (mailto:christoph.heindl@gmail.com)
# Homepage:: http://cheind.wordpress.com

require 'test/unit'
require 'ext/join'

class TestHashJoin < Test::Unit::TestCase
  def test_should_format_correctly
    j = {:name => 'christoph', :age => 28}.join('&', '=') 
    assert_equal(true, j == "name=christoph&age=28" || j == "age=28&name=christoph")
  end
  
  def test_should_format_correctly_block
    j = {:name => 'christoph', :age => 28}.join('&') do |k,v|
      "[#{k}=#{v}]"
    end
    assert_equal(true, j == "[name=christoph]&[age=28]" || j == "[age=28]&[name=christoph]")
  end
end