#
# Project:: Ruby-Snippets
# 
# Author:: Christoph Heindl  (mailto:christoph.heindl@gmail.com)
# Homepage:: http://cheind.wordpress.com
#
# == Overview
# 
# Implements <tt>Array#breakup</tt>
#

class Array
  
  # Break up the content of the array
  # - returns nil if array is empty
  # - returns the element if array has a single element
  # - returns duplicate of self if array has multiple elements
  #
  #  [].breakup # => nil
  #  [1].breakup # => 1
  #  [1,2].breakup # => [1,2]
  #
  def breakup
    if self.empty?
      return nil
    elsif self.length > 1
      return self.dup
    else
      return self.first
    end
  end
end
