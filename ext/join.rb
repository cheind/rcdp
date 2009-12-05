#
# Project:: Ruby-Snippets
# 
# Author:: Christoph Heindl  (mailto:christoph.heindl@gmail.com)
# Homepage:: http://cheind.wordpress.com
#
# == Overview
# 
# Implements <tt>Hash.join</tt>

class Hash
  
  # Joins key value pairs together by the given separators.
  #
  # +outer_sep+ is the separator string between two key-value pairs
  # +inner_sep+ is the separator string between key and values
  # 
  # If block is given it receives each key-value pair and 
  # has to return formatted string for both. In case a block
  # is given, the +inner_sep+ argument is ignored.
  #
  #  {:name => 'christoph', :age => 28}.join('&', '=')
  #  # => "name=christoph&age=28"
  #
  #  {:name => 'christoph', :age => 28}.join('&') do |k,v|
  #   "[#{k}=#{v}]"
  #  end
  #  # => "[name=christoph]&[age=28]"
  #
  def join(outer_sep, inner_sep='=')
    s = ''
    self.each do |k,v|
      if block_given?
        s += yield(k,v) + outer_sep.to_s
      else
        s += "#{k}#{inner_sep}#{v}#{outer_sep}"
      end
    end
    s.chomp(outer_sep) # Remove outer_sep from last
  end
end