# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{tabular}
  s.version = "0.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Scott Willson"]
  s.date = %q{2010-06-08}
  s.description = %q{Tabular is a Ruby library for reading, writing, and manipulating CSV, tab-delimited and Excel data.}
  s.email = %q{scott.willson@gmail.cpm}
  s.extra_rdoc_files = [
    "LICENSE",
     "README"
  ]
  s.files = [
    ".gitignore",
     "LICENSE",
     "README",
     "Rakefile",
     "VERSION",
     "lib/tabular.rb",
     "lib/tabular/column.rb",
     "lib/tabular/columns.rb",
     "lib/tabular/row.rb",
     "lib/tabular/support/object.rb",
     "lib/tabular/table.rb",
     "tabular.gemspec",
     "test/column_test.rb",
     "test/columns_test.rb",
     "test/fixtures/blank.txt",
     "test/fixtures/excel.xls",
     "test/fixtures/sample.csv",
     "test/fixtures/sample.lif",
     "test/helper.rb",
     "test/row_test.rb",
     "test/table_test.rb"
  ]
  s.homepage = %q{http://github.com/scottwillson/tabular}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Read, write, and manipulate CSV, tab-delimited and Excel data}
  s.test_files = [
    "test/column_test.rb",
     "test/columns_test.rb",
     "test/helper.rb",
     "test/row_test.rb",
     "test/table_test.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end

