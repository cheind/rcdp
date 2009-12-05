#
# Project:: Ruby-Snippets
# 
# Author:: Christoph Heindl  (mailto:christoph.heindl@gmail.com)
# Homepage:: http://cheind.wordpress.com

require 'test/unit'
require 'util/uuid.rb'

class TestUUID < Test::Unit::TestCase
  def test_fetch_from_url
    assert_nothing_raised do
      UUID.from_url
    end
  end
  
  def check_correct_format(format, method, options={})
    assert_match(format, method.call(options))
  end
  
  def check_correct_count(count, method)
    assert_equal(count, method.call(:count => count).length)
  end
  
  def test_correct_format
    check_correct_format(/^\{\w{8}-\w{4}-\w{4}-\w{4}-\w{12}\}$/, UUID.method(:from_url))
    check_correct_format(/^\w{32}$/, UUID.method(:from_url), :hyphen=>false, :bracket=>false)
    if RUBY_PLATFORM =~ /mswin/
      check_correct_format(/^\w{32}$/, UUID.method(:from_os), :hyphen=>false, :bracket=>false)
      check_correct_format(/^\{\w{8}-\w{4}-\w{4}-\w{4}-\w{12}\}$/, UUID.method(:from_os))
    end
  end
  
  def test_correct_count
    check_correct_count(3, UUID.method(:from_url))
    if RUBY_PLATFORM =~ /mswin/
      check_correct_count(3, UUID.method(:from_os))
    end
  end
end