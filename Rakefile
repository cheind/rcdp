require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc "Run all tests inside tests"
task(:default => ['test:unit'])

desc "Run all tests inside tests"
Rake::TestTask.new('test:unit') do |t|
  t.pattern = 'tests/**/*.rb'
  t.verbose = true
  t.warning = true
end

desc "Generate documentation"
Rake::RDocTask.new do |t|
  t.rdoc_dir = 'doc'
  t.rdoc_files.include('util/**/*.rb',
                       'ext/**/*.rb',
                       'dependencies/**/*.rb')
  t.options << "--all"
  t.title = "Ruby-Snippets"
end