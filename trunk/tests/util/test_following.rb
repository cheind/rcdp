#
# Project:: Ruby-Snippets
# 
# Author:: Christoph Heindl  (mailto:christoph.heindl@gmail.com)
# Homepage:: http://cheind.wordpress.com

require 'test/unit'
require 'util/following.rb'

class TestFollowing < Test::Unit::TestCase
  
  # Sample class that offers two rw properties we hook onto.
  class Window
    include FollowingHook
    
    # Access background color of window.
    attr_accessor :background
    # Access text messages overlayed to window content
    attr_accessor :text
    # Last invokation parameters to either background= or text=
    attr_accessor :last_invokation
  
    private
    # After setters are invoked update window content
    following :background=, :text= do |wnd, args|
      wnd.last_invokation = args
    end
  end
  
  def test_hook_on_window_class
    wnd = Window.new
    assert_nil(wnd.last_invokation)
    wnd.background = [1.0, 2.0, 3.0]
    assert_not_nil(wnd.last_invokation)
    assert_equal([1.0, 2.0, 3.0], wnd.last_invokation[:args][0])
    assert_equal([1.0, 2.0, 3.0], wnd.last_invokation[:return])
    wnd.text = "Show this text"
    assert_equal("Show this text", wnd.last_invokation[:args][0])
    assert_equal("Show this text", wnd.last_invokation[:return])
  end
  
  def test_hook_unknown_method
    # Throws name error upon hooking an unknown method.
    assert_raise NameError do 
      Window.instance_eval("following :unknown do |wnd,args| end")
    end
  end
  
  def test_multiple_hooks_with_no_override
    assert_raise ArgumentError do 
      klass = Class.new
      klass.module_eval(<<-eos
        include FollowingHook
        attr_accessor :a
        attr_accessor :count
        
        following :a= do |sender| sender.count = 3 end
        following :a= do |sender| sender.count = 3 end
        eos
      )
    end
  end
  
  def test_multiple_hooks_with_override
    klass = Class.new
    assert_nothing_raised do 
      klass.module_eval(<<-eos
        include FollowingHook
        attr_accessor :a
        attr_accessor :count
        
        following! :a= do |sender, args| sender.count = 0 end
        following! :a= do |sender, args| sender.count = 3 end
        eos
      )
    end
    x = klass.new
    x.a = "dummy"
    assert_equal(x.count, 3)
  end
end