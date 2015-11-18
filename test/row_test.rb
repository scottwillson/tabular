require "helper"

module Tabular
  class RowTest < Test::Unit::TestCase
    def test_new
      row = Row.new(Table.new)
      assert_equal nil, row[:city], "[]"

      assert_equal "", row.join, "join"
      assert_equal({}, row.to_hash, "to_hash")
      assert_equal "{}", row.inspect, "inspect"
      assert_equal "", row.to_s, "to_s"

      # Test each
      row.each { |c| c.nil? }
    end

    def test_new_from_hash
      row = Row.new(Table.new, { :place => "1" })
      assert_equal nil, row[:city], "[]"

      assert_equal "1", row.join, "join"
      assert_equal({ :place => "1" }, row.to_hash, "to_hash")
      assert_equal "{:place=>\"1\"}", row.inspect, "inspect"
      assert_equal "1", row.to_s, "to_s"

      # Test each
      row.each { |c| c.nil? }
    end

    def test_new_from_hash_with_string_keys
      row = Row.new(Table.new, { "place" => "1" })
      assert_equal nil, row[:city], "[]"

      assert_equal "1", row.join, "join"
      assert_equal({ :place => "1" }, row.to_hash, "to_hash")
      assert_equal "{:place=>\"1\"}", row.inspect, "inspect"
      assert_equal "1", row.to_s, "to_s"

      # Test each
      row.each { |c| c.nil? }

      assert_equal({ "place" => "1" }, row.source, "source")
    end

    def test_set
      table = Table.new([[ "planet", "star" ]])
      row = Row.new(table, [ "Mars", "Sun" ])

      assert_equal "Sun", row[:star], "row[:star]"

      row[:star] = "Solaris"
      assert_equal "Solaris", row[:star], "row[:star]"

      row[:astronaut] = "Buzz"
      assert_equal "Buzz", row[:astronaut], "row[:astronaut]"
    end

    def test_join
      table = Table.new([[ "planet", "star" ]])
      row = Row.new(table, [ "Mars", "Sun" ])
      assert_equal "MarsSun", row.join, "join"
      assert_equal "Mars-Sun", row.join("-"), "join '-'"
    end

    def test_to_hash
      table = Table.new([[ "planet", "star", "" ]])
      row = Row.new(table, [ "Mars", "Sun", "" ])
      assert_equal({ :planet => "Mars", :star => "Sun"}, row.to_hash, "to_hash")
    end

    def test_inspect
      table = Table.new([[ "planet", "star" ]])
      row = Row.new(table, [ "Mars", "Sun" ])
      assert_match %r{:planet=>"Mars"}, row.inspect, "inspect"
      assert_match %r{:star=>"Sun"}, row.inspect, "inspect"
    end

    def test_to_s
      table = Table.new([[ "planet", "star" ]])
      row = Row.new(table, [ "Mars", "Sun" ])
      assert_equal "Mars, Sun", row.to_s, "to_s"
    end

    def test_render
      table = Table.new([[ "planet", "star" ]])
      table.renderers[:planet] = StarRenderer
      row = Row.new(table, [ "Mars", "Sun" ])
      assert_equal "****", row.render("planet"), "render"
      assert_equal "****", row.render(:planet), "render"
      assert_equal "****", row.render(row.columns.first), "render"
    end

    def test_render_with_no_renderer
      table = Table.new([[ "planet", "star" ]])
      row = Row.new(table, [ "Mars", "Sun" ])
      assert_equal "Mars", row.render("planet"), "render"
    end

    def test_previous_next
      table = Table.new([[ "planet", "star" ]])
      table << [ "Mars", "Sun" ]
      table << [ "Jupiter", "Sun" ]

      assert_equal nil, table.rows.first.previous, "previous of first Row"
      assert_equal "Mars", table.rows.last.previous[:planet], "previous"

      assert_equal "Jupiter", table.rows.first.next[:planet], "next of first Row"
      assert_equal nil, table.rows.last.next, "next"
    end

    def test_each_with_key
      table = Table.new([[ "planet", "star" ]])
      table << [ "Mars", "Sun" ]
      results = []
      table.rows.first.each_with_key do |key, value|
        results << [ key, value ]
      end
      assert_equal [ [ :planet, "Mars" ], [ :star, "Sun" ] ], results
    end

    def test_invalid_date_raises_exception
      table = Table.new([[ "launched_date" ]])
      row = Row.new(table, [ "99/z/99" ])
      assert_raise ArgumentError do
        row[:launched_date]
      end
    end

    def test_parse_compact_american_dates
      table = Table.new([[ "launched_date" ]])
      assert_equal Date.new(1999, 1, 1), Row.new(table, [ "1/1/99" ])[:launched_date], "1/1/99"
      assert_equal Date.new(2000, 8, 28), Row.new(table, [ "8/28/00" ])[:launched_date], "8/28/00"
      assert_equal Date.new(2008, 12, 31), Row.new(table, [ "12/31/08" ])[:launched_date], "12/31/08"
    end

    def test_to_space_delimited
      table = Table.new([[ "planet", "star" ]])
      row = Row.new(table, [])
      assert_equal "             ", row.to_space_delimited

      row = Row.new(table, [ "Mars", "Sun" ])
      assert_equal "Mars     Sun ", row.to_space_delimited
    end

    def test_last
      table = Table.new([[ "planet", "star" ]])
      table << [ "Mars", "Sun" ]

      row = table.rows[0]
      assert row.last?, "last? (and first)"

      table << [ "Earth", "Sun" ]

      row = table.rows[0]
      assert !row.last?, "last?"

      row = table.rows[1]
      assert row.last?, "last?"
    end

    def test_delete_blank_rows
      table = Table.new([[ "planet", "star" ]])
      table << [ "", "   " ]
      table << [ "Mars", "Sun" ]
      table << [ "Jupiter", "Sun" ]
      table << [ "", nil ]

      table.delete_blank_rows!

      assert_equal 2, table.rows.size, "rows"

      assert_equal nil, table.rows[0].previous
      assert_equal "Jupiter, Sun", table.rows[0].next.to_s

      assert_equal "Mars, Sun", table.rows[1].previous.to_s
      assert_equal nil, table.rows[1].next
    end

    class StarRenderer
      def self.render(column, row)
        row[column.key].gsub(/\w/, "*")
      end
    end
  end
end
