#
# Project:: Ruby-Snippets
# 
# Author:: Christoph Heindl  (mailto:christoph.heindl@gmail.com)
# Homepage:: http://cheind.wordpress.com
#
# == Overview
# 

require 'erb'

module Dependencies
  
  def Dependencies.to_dot(graph, template = 'dependencies/graph.template')
    binding = graph.send(:binding)
    ERB.new(File.read(template)).result(binding)
  end
  
  def Dependencies.to_dot_file(graph, filename = 'graph.dot', template = "#{File.dirname(__FILE__)}/graph.template")
    File.open(filename, 'w') do |f|
      f.write(Dependencies.to_dot(graph, template))
    end
  end
  
end