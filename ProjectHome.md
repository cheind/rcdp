# Introduction #
**rcdp** is a regular expression based ruby parsing utility to interfere C++ include file dependencies. **rcdp** works by recursively parsing files.

Each file is assigned to graph vertex (based on customizable rules) and all of its dependencies are recorded as directed graph edges. When all files are parsed a transitive reduction on the directed graph is performed and the result is written in [GraphViz Dot](http://www.graphviz.org) format.

**rcdp** evolved from the need to understand inter [Boost](http://www.boost.org) project dependencies. **rcdp** itself does not depend on C/C++ include directives and can thus be extended parse dependencies in 'any' language (on a quite primitive level).

# Installation #
To run rcdp you need a [Ruby](http://www.ruby-lang.org/de/) interpreter and the Ruby Graph Library [(RGL)](http://rgl.rubyforge.org/rgl/index.html).

RGL can be installed via ruby gems by invoking
```
gem install rgl
```

To run the tests you need to install [Rake](http://rake.rubyforge.org/) by
```
gem install rake
```

# Parsing Boost #

The Boost inter project dependencies can be parsed by

```
ruby dependencies/boost.rb <path to boost include directory>
```

The resulting dot file can be nicely translated into an image by

```
dot -Tpng -O graph.dot
```

# Parsing C/C++ Projects #

C/C++ projects can be parsed by slightely modifying

```
ruby dependencies/boost.rb
```

The file comments should guide you to adapt rcdp for your project.

# Parsing Custom Projects #

The parser is generic and can work on arbitrary files and dependency rules. The unit tests contain a contrived example.