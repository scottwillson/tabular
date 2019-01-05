# frozen_string_literal: true

require "helper"

module Tabular
  class ColumnTest < Minitest::Test
    include Tabular::Blank

    def test_new_nil
      column = Column.new(nil, nil)
      assert_equal "", column.to_s, "blank column to_s"
      assert_nil column.key, "blank column key"
    end

    def test_new
      assert_equal :date, Column.new(nil, nil, "date").key, "column key"
      assert_equal :date, Column.new(nil, nil, :date).key, "column key"
      assert_equal :date, Column.new(nil, nil, "Date").key, "column key"
      assert_equal :date, Column.new(nil, nil, " Date  ").key, "column key"
      assert_equal :date, Column.new(nil, nil, "DATE").key, "column key"
      assert_equal :start_date, Column.new(nil, nil, "StartDate").key, "column key"
      assert_equal :start_date, Column.new(nil, nil, "Start Date").key, "column key"
    end

    def test_type
      column = Column.new(nil, nil, "name")
      assert_equal :name, column.key, "key"
      assert_equal :string, column.column_type, "column_type"

      column = Column.new(nil, nil, "date")
      assert_equal :date, column.key, "key"
      assert_equal :date, column.column_type, "column_type"
    end

    def test_cells
      data = [
        { place: "1", name: "Bernard Hinault" },
        { place: "2", name: "Greg Lemond" }
      ]
      table = Table.new(data)
      column = table.columns[:place]
      assert_equal %w[1 2], column.cells
    end

    def test_max
      data = [
        { place: "1", name: "Bernard Hinault" },
        { place: "2", name: "Greg Lemond" }
      ]
      table = Table.new(data)

      assert_equal "2", table.columns[:place].max
      assert_equal "Greg Lemond", table.columns[:name].max
    end

    def test_precision
      data = [
        { place: "1", age: 22, points: 10.75 },
        { place: "2", age: 30, points: 12.000 }
      ]
      table = Table.new(data)

      assert_equal 0, table.columns[:place].precision
      assert_equal 0, table.columns[:age].precision
      assert_equal 2, table.columns[:points].precision
    end

    def test_precision_with_mixed_zeros
      data = [
        { place: "1", age: 22, points: 12.001 }
      ]
      table = Table.new(data)
      assert_equal 3, table.columns[:points].precision
    end

    def test_width
      data = [
        { place: "1", name: "Bernard Hinault" },
        { place: "2", name: "Greg Lemond" }
      ]
      table = Table.new(data)

      assert_equal 5, table.columns[:place].width
      assert_equal 15, table.columns[:name].width
    end

    def test_to_space_delimited
      table = Table.new([%w[planet star]])
      assert_equal "planet", table.columns[:planet].to_space_delimited
    end

    def test_symbolize
      mapper = ColumnMapper.new
      assert_equal :place, mapper.symbolize(";place")
      assert_equal :"#", mapper.symbolize("#")
      assert_equal :"rider_#", mapper.symbolize("Rider #")
      assert_equal :"cat.", mapper.symbolize("Cat.")
      assert_equal :"team/club", mapper.symbolize("Team/Club")
    end
  end
end
