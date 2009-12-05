#
# Project:: Ruby-Snippets
# 
# Author:: Christoph Heindl  (mailto:christoph.heindl@gmail.com)
# Homepage:: http://cheind.wordpress.com
#
# == Overview
# 
# Taken from:
# http://api.rubyonrails.org/classes/ActiveSupport/CoreExtensions/Hash/ReverseMerge.html

class Hash
  
  # Reversely merge attributes of the given hash into self
  # unless they are already present in self.
  def reverse_merge(other)
    other.merge(self)
  end
  
  # Reversely merge attributes of the given hash into self
  # unless they are already present in self.
  # Modifies receiver
  def reverse_merge!(other)
    self.replace(reverse_merge(other))
  end
end