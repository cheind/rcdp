#
# Project:: Ruby-Snippets
# 
# Author:: Christoph Heindl  (mailto:christoph.heindl@gmail.com)
# Homepage:: http://cheind.wordpress.com
#
# == Overview
# 
# Ruby script that builds inter-project dependencies of boost (http://www.boost.org)
# via include file parsing.

require 'dependencies/walker'
require 'dependencies/dot'

def usage
  puts "ruby #{$0} path_to_boost"
  exit(1)
end

# Sanity check for command line arguments
usage unless ARGV.length == 1
exit(1) unless File.directory?(ARGV[0])

boost_dir = ARGV[0]

# Instance a walker that records files and dependencies between files
w = Dependencies::Walker.new

# Record all file paths of files ending with '.hpp' residing in any directory 
# nested one-level below boost root include directory
w.index(boost_dir, 'boost/*/**/*.hpp') do |path|
  # When such a file is discoverd, the nested directory name is used as vertex 
  # name in the graph
  path.split('/')[1]
end

# Index all files residing directly in the boost root include directory.
w.index(boost_dir, 'boost/*.hpp') do |path|
  # The vertex named is determined from the following rule:
  # When a nested directory with the same name as the file (except for the extension)
  # exists, then the directory name is used as vertex name.
  # Else, the file is accumulated in a vertex named 'utilities'
  dirname_exists = File.directory?(File.join(boost_dir, 'boost/', File.basename(path, '.hpp')))
  if dirname_exists
    File.basename(path, '.hpp')
  else
    'utilities'
  end
end

# Read the content of all header files inside the boost directory.
w.parse(boost_dir,'boost/**/*.hpp') do |path, file|
  # Record dependencies in file by matching include statements
  dependencies = []
  while (line = file.gets)
    if line =~ /\#include\s+[\"<]([^\">]+)?/
      # Try looking up the file inside the boost directory.
      # On success use the same name as the recorded file.
      vertex_name = w.try_resolve($1, boost_dir)
      dependencies << vertex_name if vertex_name
    end
  end
  dependencies
end

# Reduce the graph by removing all edges between vertex v -> w, when 
# and a path v -> ... -> w exists.
mygraph = w.graph.transitive_reduction
# Write to dot file using the default template 'dependencies\graph.template'
Dependencies.to_dot_file(mygraph)