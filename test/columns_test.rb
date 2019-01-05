require "helper"

module Tabular
  class ColumnsTest < Minitest::Test
    def test_new_blank
      columns = Columns.new(nil, [])
      assert_equal false, columns.has_key?(:name), "has_key? :name"
      assert_nil columns[:name], "[:name]"
      assert_nil columns.index(nil), "index"
      assert_nil columns.index(""), "index"
      assert_nil columns.index(:name), "index"
      columns.each { |c| c.nil? }
    end

    def test_new
      columns = Columns.new(nil, ["date", "first name", "LastName"])
      assert_equal false, columns.has_key?(:location), "has_key? :location"
      assert_equal true, columns.has_key?(:date), "has_key? :date"
      assert_equal true, columns.has_key?(:first_name), "has_key? :first_name"
      assert_equal true, columns.has_key?(:last_name), "has_key? :last_name"
      assert_equal false, columns.has_key?("first name"), "has_key? 'first name'"

      column = columns[:first_name]
      assert_equal :first_name, column.key, "column[:first_name] Column key"

      assert_equal 1, columns.index(:first_name), "index of :first_name"
    end

    def test_mapping
      columns = Columns.new(nil, [], CityMapper.new)
      assert_equal :city, Column.new(Table.new, columns, :location).key, "column key"
    end

    def test_render
      columns = Columns.new(Table.new, ["date", "first name", "LastName"])
      assert_equal "date", columns.first.render
    end

    def test_renderer
      columns = Columns.new(nil, ["date", "first name", "LastName"])
      columns.renderer = TestRenderer
      assert_equal "Date", columns.first.render
    end

    def test_delete
      columns = Columns.new(nil, ["date", "first name", "LastName"])
      columns.delete :date

      columns_from_each = []
      columns.each { |c| columns_from_each << c.key }
      assert_equal [ :first_name, :last_name ], columns_from_each, "column keys from #each"

      assert_equal false, columns.has_key?(:date), "has_key? :date"
      assert_equal true, columns.has_key?(:first_name), "has_key? :first_name"
      assert_equal 0, columns.index(:first_name), "index of :first_name"
      assert_equal 1, columns.index(:last_name), "index of :last_name"
    end

    def test_push_onto_blank
      columns = Columns.new(nil, [])
      columns << "city state"
      assert_equal true, columns.has_key?(:city_state), "has_key? :city_state"
      assert_equal 0, columns.index(:city_state), "index of new column"

      column = columns[:city_state]
      assert_equal :city_state, column.key, "column[:city_state] Column key"
    end

    def test_push
      columns = Columns.new(nil, ["first", "second"])
      columns << "third"
      assert_equal true, columns.has_key?(:third), "has_key? :third"
      assert_equal 0, columns.index(:first), "index of existing column"
      assert_equal 1, columns.index(:second), "index of existing column"
      assert_equal 2, columns.index(:third), "index of new column"

      column = columns[:third]
      assert_equal :third, column.key, "column[:third] Column key"
    end

    class TestRenderer
      def self.render_header(column)
        key = column.key.to_s
        (key.slice(0) || key.chars('')).upcase + (key.slice(1..-1) || key.chars('')).downcase
      end
    end

    class CityMapper < Tabular::ColumnMapper
      def map(key)
        if key == :location
          key = :city
        end
        super key
      end
    end
  end
end
