#
# Project:: Ruby-Snippets
# 
# Author:: Christoph Heindl  (mailto:christoph.heindl@gmail.com)
# Homepage:: http://cheind.wordpress.com
#
# == Overview
# 
#

require 'logger'
require 'pathname'
require 'dependencies/has_path.rb'
require 'rubygems'
require 'rgl/adjacency'
require 'rgl/connected_components'
require 'rgl/transitivity'


module Dependencies
  
  # Walker provides methods to generate a dependency graph between files.
  # First, files matching globbing path patterns are enumerated and assigned a
  # dependency vertex name. Next, dependencies between vertices are determined by 
  # parsing through recorded files.
  #
  class Walker
    attr_reader :graph
    
    # Initialize walker with a reporting instance
    def initialize(logger = Logger.new(STDOUT))
      @graph = RGL::DirectedAdjacencyGraph.new
      @path_to_vertex = {}
      @logger = logger
      on_unknown_vertex do |path, from, to|
        @logger.error("In '#{path}': Dependency target '#{to}' not listed.")
      end
      on_cycle do |path, from, to|
        @logger.error("In '#{path}': Cannot add cyclic dependency from '#{from}' to '#{to}'.") unless from == to
      end
    end
    
    # Record files matching globbing path patterns.
    #
    # Records file paths only and assigns a dependency vertex name
    # to them.
    #
    # root_dir:: is the base directory of files to search
    # path_pattern:: is globbing pattern to match files inside the root_dir
    # *path_patterns:: arbitrary number of additional patterns
    # mapping:: is the block executed when indexing stumbles upon a file. Its task is
    # convert the path to a dependency vertex name.
    #
    def index(root_dir, path_pattern, *path_patterns, &mapping)
      strip_from_start, path_patterns = convert_path_patterns(root_dir, path_pattern, path_patterns)
      files = Dir.glob(path_patterns, File::FNM_PATHNAME).delete_if do |path|
        File.directory?(path)
      end
      @logger.info("Indexing #{files.length} files from #{path_patterns.length} pattern(s).")
      files.each do |path|
        unless @path_to_vertex.include?(path)
          vertex_name = mapping.call(path[strip_from_start..-1])
          if vertex_name
            @graph.add_vertex(vertex_name)
            @path_to_vertex[path] = vertex_name
          end
        end
      end
    end
    
    # Parse files matching globbing path patterns.
    #
    # Parses the content of previosly recorded files (see method <tt>Walker#index</tt>)
    # if any globbing path patterns is matched. If such a file is found an instance of <tt>File</tt>
    # along with the path is passed to the block. The block is responsible for generating a list of
    # dependencies.
    #
    # root_dir:: is the base directory of files to search
    # path_pattern:: is globbing pattern to match files inside the root_dir
    # *path_patterns:: arbitrary number of additional patterns
    # mapping:: is the block called with path and file. Should return dependencies as 
    # an array of vertex names.
    #
    def parse(root_dir, path_pattern, *path_patterns, &block)
      strip_from_start, path_patterns = convert_path_patterns(root_dir, path_pattern, path_patterns)
      path_patterns.each do |pattern|
        counter = 0
        @logger.info("Parsing files matching pattern '#{pattern}'.")
        @path_to_vertex.each do |path, vertex_name|
          counter += 1
          if File.fnmatch?(pattern, path, File::FNM_PATHNAME)
            parse_file(path, vertex_name, strip_from_start, block)
          end
          @logger.info("#{counter} files parsed.") if counter % 1000 == 0
        end
      end
    end
    
    # Specify the block to call when an unknown vertex is encountered while adding
    # a dependency
    #
    #  walker = Dependencies::Walker.new
    #  walker.on_unknown_vertex do |path, from, to|
    #   puts "In '#{path}': Dependency target '#{to}' not listed."
    #  end
    #
    def on_unknown_vertex(&f)
      @on_unknown_vertex = f
    end
    
    # Specify the block to call when a cylce between two vertices is encountered 
    # while adding a dependency.
    #
    #  walker = Dependencies::Walker.new
    #  walker.on_cylce do |path, from, to|
    #   puts "In '#{path}': Cannot add cyclic dependency from '#{from}' to '#{to}'."
    #  end
    #
    def on_cycle(&f)
      @on_cycle = f
    end
    
    # Try to map from path to vertex name by lookup.
    #
    def resolve(path)
      @path_to_vertex[
        Pathname.new(
          convert_backslashes(path)
        ).cleanpath.to_s
      ]
    end
    
    # Try to map from multiple paths to vertex name.
    #
    # basename:: basename of file
    # *root_dirs:: directories to lookup <tt>basename</tt> in
    def try_resolve(basename, *root_dirs)
      root_dirs << "./" if root_dirs.empty?
      root_dirs.each do |path|
        vertex_name = self.resolve(File.join(path, basename))
        return vertex_name if vertex_name
      end
      nil
    end
    
    protected
    
    def parse_file(path, vertex_name, strip_from_start, block)
      f = File.open(path, 'r')
      begin
        dependencies = block.call(path[strip_from_start..-1], f)
        self.add_dependencies(path, vertex_name, dependencies.to_a) if dependencies
      rescue Exception => e
        @logger.error("Exception raised: '#{e.message}' while parsing '#{path}'")              
      ensure
        f.close
      end
    end
  
    # Replaces '\' with '/' in path names
    def convert_backslashes(path)
      path.gsub(/\\/, '/')
    end
    
    def convert_path_patterns(root_dir, path_pattern, path_patterns)
      path_patterns.unshift(path_pattern)
      clean_root = Pathname.new(convert_backslashes(root_dir)).to_s
      strip_from_start = clean_root.length + 1
      path_patterns.map! do |pattern|
        File.join(clean_root, pattern)
      end
      return strip_from_start, path_patterns
    end
      

    # Add dependencies if possible from a single source to multiple targets.
    def add_dependencies(from_path, from, tos)
      tos.each do |to|
        # Test if on-the-fly vertex generation is allowed when target vertex is not recorded
        if !@graph.has_vertex?(to)
          @on_unknown_vertex.call(from_path, from, to)
        elsif @graph.has_path?(to, from) 
          @on_cycle.call(from_path, from, to)
        else
          @graph.add_edge(from, to)
        end
      end  
    end
    
  end
end

