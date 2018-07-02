$:.push File.expand_path("../lib", __FILE__)

require "tabular/version"

Gem::Specification.new do |s|
  s.name = "tabular"
  s.version = Tabular::VERSION

  s.authors = ["Scott Willson"]
  s.description = "Tabular is a Ruby library for reading, writing, and manipulating CSV, tab-delimited and Excel data."
  s.email = "scott.willson@gmail.com"
  s.extra_rdoc_files = [
    "LICENSE",
    "README"
  ]
  s.files = [
    "Gemfile",
    "Gemfile.lock",
    "LICENSE",
    "README",
    "Rakefile",
    "lib/tabular/tables/file_reading.rb",
    "lib/tabular.rb",
    "lib/tabular/blank.rb",
    "lib/tabular/column.rb",
    "lib/tabular/column_mapper.rb",
    "lib/tabular/columns.rb",
    "lib/tabular/keys.rb",
    "lib/tabular/renderer.rb",
    "lib/tabular/row.rb",
    "lib/tabular/table.rb",
    "lib/tabular/version.rb",
    "lib/tabular/zero.rb",
    "tabular.gemspec"
  ]
  s.homepage = "http://github.com/scottwillson/tabular"
  s.require_paths = ["lib"]
  s.summary = "Read, write, and manipulate CSV, tab-delimited and Excel data"
end
