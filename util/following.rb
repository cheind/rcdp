#
# Project:: Ruby-Snippets
# 
# Author:: Christoph Heindl  (mailto:christoph.heindl@gmail.com)
# Homepage:: http://cheind.wordpress.com
#
# == Overview
# 
# Implements <tt>following</tt> and <tt>following!</tt>
# utility methods to hook into instance methods and execute
# custom code after hooked methods are called.
#
# See discussion at
# http://cheind.blogspot.com/2008/12/method-hooks-in-ruby.html
#

# Contains methods to hook method calls
module FollowingHook
  
  module ClassMethods
    
    private
    
    # Hook the provided instance methods so that the block 
    # is executed directly after the specified methods have been invoked.
    #
    # There can only be one hook for a single instance method. Further attempts
    # to hook already hooked methods will result in an ArgumentError
    #
    # +syms+:: is list of method symbols or stringified names to hook on
    # +block+:: is the block to execute after hooked method has been invoked.
    #
    # +block+ can receive two arguments: the receiver of the method and an argument hash
    # which contains the invoked method name <tt>:method</tt>, the arguments passed to
    # the method <tt>:args</tt> and the return value of the method <tt>:return</tt>.
    # See documentation of <tt>__hook__</tt> for a detailed discussion.
    #
    #   class Object
    #     include FollowingHook
    #     following :system do |receiver, args|
    #       p "#{args[:method]} called with arguments #{args[:args].join(",")}"
    #       p "return value was #{args[:return]}"
    #     end
    #   end
    #
    #   system('ruby --version')
    #   # => ruby 1.8.6 (2008-08-11 patchlevel 287) [i386-mswin32]
    #   # => "system called with arguments ruby --version"
    #   # => "return value was true"
    #   # => true
    #
    def following(*syms, &block)
      syms.each do |sym|
        backup_name = ::FollowingHook.hook_name_for_method(sym)
        raise ArgumentError.new("Method #{sym} already hooked.") if __hooked__?(backup_name)
        __backup__(sym, backup_name)
        __hook__(sym, backup_name, &block)
      end
    end
    
    # Identical to <tt>following</tt> except that if method has
    # already been hooked, hook will be overridden which call
    # to given block
    #
    # See documentation of <tt>following</tt>
    #
    def following!(*syms, &block)
      syms.each do |sym|
        backup_name = ::FollowingHook.hook_name_for_method(sym)
        __backup__(sym, backup_name) unless __hooked__?(backup_name)
        __hook__(sym, backup_name, &block)
      end
    end
    
    # This method will backup an existing instance method (create a copy)
    # and privatize it.
    #
    def __backup__(sym, backup_name)
      alias_method backup_name, sym        # Backup original method
      private backup_name                  # Make backup private
    end
    
    # Defines or overrides a a method with a call to the original
    # method and an invokation of the block.
    #
    # sym:: method name to define/override
    # backup_name:: name of the orginal method
    # block:: block to call after hooked method is called.
    # In case the block has
    # - 0 arguments: nothing is passed as argument to the block
    # - 1 arguments: the receiver of the method call is passed
    # - 2 arguments: the receiver and a hash of options containing the method call arguments is passed.
    #
    def __hook__(sym, backup_name, &block)
      define_method sym do |*args|    # Replace method
        ret = __send__ backup_name, *args  # Invoke backup
        case block.arity              # Based on the number of block arguments
        when 0 : yield
        when 1 : yield(self)
        when 2 : yield(self, :method => sym, :args => args, :return => ret)
        end
        ret                           # Forward return value of method
      end
    end
    
    # Test if method has already been hooked.
    def __hooked__?(backup_name)
      private_instance_methods.include?(backup_name)
    end
  end
  
  # Standard identifier for the backup of a hooked method.
  def FollowingHook.hook_name_for_method(sym)
    RUBY_VERSION >= '1.9.0' ? "__#{sym}__hooked__".to_sym : "__#{sym}__hooked__"
  end
  
  # On inclusion, we extend the receiver by the defined class-methods
  # This is an ruby idiom for defining class methods within a module.
  def FollowingHook.included(base)
    base.extend(ClassMethods)
  end
end