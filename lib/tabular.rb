# frozen_string_literal: true

require "rubygems"

$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../lib")

require "tabular/blank"
require "tabular/keys"
require "tabular/zero"

require "tabular/column_mapper"
require "tabular/column"
require "tabular/columns"
require "tabular/renderer"
require "tabular/row"
require "tabular/tables/file_reading"
require "tabular/table"
