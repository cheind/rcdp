#
# Project:: Ruby-Snippets
# 
# Author:: Christoph Heindl  (mailto:christoph.heindl@gmail.com)
# Homepage:: http://cheind.wordpress.com

require 'test/unit'
require 'dependencies/walker'

class TrueTest < Test::Unit::TestCase

  def test_should_index_correctly
    walker = Dependencies::Walker.new(Logger.new('walker.log'))
    path_to_files = 'tests/dependencies/files'
    walker.index(path_to_files, '*.txt') do |path|
      File.basename(path, '.txt')
    end
    assert_not_nil(walker.resolve(path_to_files + '/a.txt'))
    assert_not_nil(walker.resolve(path_to_files + '/b.txt'))
    assert_not_nil(walker.resolve(path_to_files + '/c.txt'))
    assert_not_nil(walker.resolve(path_to_files + '/d.txt'))
  end
  
  def test_should_parse_correctly
    walker = Dependencies::Walker.new(Logger.new('walker.log'))
    path_to_files = 'tests/dependencies/files'
    walker.index(path_to_files, '*.txt') do |path|
      File.basename(path, '.txt')
    end
    walker.parse(path_to_files, '*.txt') do |path, file|
      dependencies = []
      while (line = file.gets)
        if line =~ /^->\s*(\w+)/
          dependencies << File.basename($1, '.txt')
        end
      end
      dependencies
    end
    assert_equal(true, walker.graph.has_edge?('a', 'b'))
    assert_equal(true, walker.graph.has_edge?('b', 'c'))
    assert_equal(false, walker.graph.has_edge?('c', 'd') && walker.graph.has_edge?('d', 'b'))
  end
  
  def test_should_parse_correctly_with_cycle
    walker = Dependencies::Walker.new(Logger.new('walker.log'))
    # Explicitely allow cycles
    walker.on_cycle do |path, from, to|
      walker.graph.add_edge(from, to)
    end
    
    path_to_files = 'tests/dependencies/files'
    walker.index(path_to_files, '*.txt') do |path|
      File.basename(path, '.txt')
    end
    walker.parse(path_to_files, '*.txt') do |path, file|
      dependencies = []
      while (line = file.gets)
        if line =~ /^->\s*(\w+)/
          dependencies << File.basename($1, '.txt')
        end
      end
      dependencies
    end
    assert_equal(true, walker.graph.has_edge?('a', 'b'))
    assert_equal(true, walker.graph.has_edge?('b', 'c'))
    assert_equal(true, walker.graph.has_edge?('c', 'd'))
    assert_equal(true, walker.graph.has_edge?('d', 'b'))
  end
end