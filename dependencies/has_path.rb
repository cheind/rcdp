#
# Project:: Ruby-Snippets
# 
# Author:: Christoph Heindl  (mailto:christoph.heindl@gmail.com)
# Homepage:: http://cheind.wordpress.com
#
# == Overview
#
# Contains the <tt>RGL::Graph#has_path?</tt> implementation
#

require 'set'

module RGL
  module Graph 
    
    # Is w reachable from v?
    def has_path?(v, w)
      visited = Set.new
      stack = [v]
      found = false  
      while ((e = stack.pop) && !found)
        visited << e
        if e != w
          self.each_adjacent(e) do |dep|
            stack.push(dep) unless visited.include?(dep)
          end
        else
          found = true
        end
      end
      found
    end
  end
end