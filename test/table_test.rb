require "helper"

module Tabular
  class TableTest < Test::Unit::TestCase
    def test_read_from_blank_txt_file
      Table.read(File.expand_path(File.dirname(__FILE__) + "/fixtures/blank.txt"))
    end

    def test_read_quoted_txt_file
      Table.read(File.expand_path(File.dirname(__FILE__) + "/fixtures/quoted.txt"))
    end

    # "Place ","Number","Last Name","First Name","Team","Category Raced"
    # "1","189","Willson","Scott","Gentle Lover","Senior Men 1/2/3","11",,"11"
    # "2","190","Phinney","Harry","CCCP","Senior Men 1/2/3","9",,
    # "3","10a","Holland","Steve","Huntair","Senior Men 1/2/3",,"3",
    # "dnf","100","Bourcier","Paul","Hutch's","Senior Men 1/2/3",,,"1"
    def test_read_from_csv
      table = Table.read(File.expand_path(File.dirname(__FILE__) + "/fixtures/sample.csv"))
      assert_equal 4, table.rows.size, "rows"

      assert_equal "1", table[0][:place], "0.0"
      assert_equal "189", table[0][:number], "0.1"
      assert_equal "Willson", table[0][:last_name], "0.2"
      assert_equal "Scott", table[0][:first_name], "0.3"
      assert_equal "Gentle Lover", table[0][:team], "0.4"

      assert_equal "dnf", table[3][:place], "3.0"
      assert_equal "100", table[3][:number], "3.1"
      assert_equal "Bourcier", table[3][:last_name], "3.2"
      assert_equal "Paul", table[3][:first_name], "3.3"
      assert_equal "Hutch's", table[3][:team], "3.4"
    end

    def test_read_from_excel
      table = Table.read(File.expand_path(File.dirname(__FILE__) + "/fixtures/excel.xls"))
      assert_equal Date.new(2006, 1, 20), table[0][:date], "0.0"
    end

    def test_read_from_xlsx
      table = Table.read(File.new(File.expand_path(File.dirname(__FILE__) + "/fixtures/excel.xlsx")))
      assert_equal Date.new(2006, 1, 20), table[0][:date], "0.0"
      table.strip!
      assert_equal 97202, table[0][:zip], "integer field"
      assert_equal "97202-1304", table[0][:"zip+4"], "integer field"
      assert_equal 45296.700000000004, table[0][:start], "time field"
      assert_equal "AZ314", table[0][:event_id], "alpha field"
      assert_equal 15.75, table[0][:price], "decimal field"
    end

    def test_read_as
      table = Table.read(File.expand_path(File.dirname(__FILE__) + "/fixtures/sample.lif"), :as => :csv)
      assert_equal 4, table.rows.size, "rows"
    end

	    def test_column_map
	      data = [
		[ "nom", "equipe", "homme" ],
		[ "Hinault", "Team Z", "true" ]
	      ]
	      table = Table.new
	      table.column_mapper = TestColumnsMapper.new
	      table.rows = data
	      assert_equal "Hinault", table.rows.first[:name], ":name"
	      assert_equal "Team Z", table.rows.first[:team], ":team"
	      assert_equal true, table.rows.first[:homme?], "boolean"
	    end

    def test_new_with_hashes
      data = [
        { :place => "1", :name => "Bernard Hinault" },
        { :place => "2", :name => "Greg Lemond" }
      ]
      table = Table.new(data)
      assert_equal 2, table.rows.size, "size"
      assert_equal data[0], table.rows[0].to_hash
      assert_equal data[1], table.rows[1].to_hash
    end

    def test_row_mapper_class_method
      data = [
        [ :place, "1", :name, "Bernard Hinault" ],
      ]

      table = Table.new
      table.row_mapper = StatelessTestMapper
      table.rows = data

      assert_equal 1, table.rows.size, "size"
      assert_equal({ :place => "1", :name => "Bernard Hinault" }, table.rows[0].to_hash)
    end

    def test_row_mapper
      data = [
        [ :place, "1", :name, "Bernard Hinault" ],
      ]

      table = Table.new
      table.row_mapper = TestMapper.new
      table.rows = data

      assert_equal 1, table.rows.size, "size"
      assert_equal({ :place => "1", :name => "Bernard Hinault" }, table.rows[0].to_hash)
    end

    def test_delete_blank_columns
      data = [
        [ "nom", "equipe", "homme", "age" ],
        [ "Hinault", "", "true", "0" ]
      ]

      table = Table.new
      table.rows = data

      table.delete_blank_columns!

      assert_equal 1, table.rows.size, "size"
      assert_equal({ :nom => "Hinault", :homme => "true" }, table.rows[0].to_hash)
    end

    def test_delete_blank_columns_exceptions
      data = [
        [ "nom", "equipe", "homme", "age" ],
        [ "Hinault", "", "true", "0" ]
      ]

      table = Table.new
      table.rows = data

      table.delete_blank_columns! :except => [ :equipe ]

      assert_equal 1, table.rows.size, "size"
      assert_equal({ :nom => "Hinault", :equipe => "", :homme => "true" }, table.rows[0].to_hash)
    end

    def test_delete_blank_columns_empty_table
      Table.new.delete_blank_columns!
    end

    def test_delete_homogenous_columns
      Table.new.delete_homogenous_columns!

      data = [
        [ "nom", "equipe", "homme", "age" ],
        [ "Hinault", "", "true", "30" ],
        [ "Lemond", "", "true", "20" ],
        [ "Hinault", "", "true", "30" ]
      ]

      table = Table.new
      table.rows = data

      table.delete_homogenous_columns!

      assert_equal 3, table.rows.size, "size"
      assert_equal({ :nom => "Hinault", :age => "30" }, table.rows[0].to_hash)
      assert_equal({ :nom => "Lemond", :age => "20" }, table.rows[1].to_hash)
      assert_equal({ :nom => "Hinault", :age => "30" }, table.rows[2].to_hash)
    end

    def test_delete_homogenous_columns_with_exceptions
      data = [
        [ "nom", "equipe", "homme", "age" ],
        [ "Hinault", "", "true", "30" ],
        [ "Lemond", "", "true", "20" ],
        [ "Hinault", "", "true", "30" ]
      ]

      table = Table.new
      table.rows = data

      table.delete_homogenous_columns!(:except => [ :homme ])

      assert_equal 3, table.rows.size, "size"
      assert_equal({ :nom => "Hinault", :homme => "true", :age => "30" }, table.rows[0].to_hash)
      assert_equal({ :nom => "Lemond", :homme => "true", :age => "20" }, table.rows[1].to_hash)
      assert_equal({ :nom => "Hinault", :homme => "true", :age => "30" }, table.rows[2].to_hash)
    end

    def test_delete_homogenous_columns_single_row
      Table.new.delete_homogenous_columns!

      data = [
        [ "nom", "equipe", "homme", "age" ],
        [ "Hinault", "", "true", "30" ],
      ]

      table = Table.new
      table.rows = data

      table.delete_homogenous_columns!

      assert_equal 1, table.rows.size, "size"
      assert_equal({ :nom => "Hinault", :equipe => "", :homme => "true", :age => "30" }, table.rows[0].to_hash)
    end

    def test_delete_column
      data = [
        { :place => "1", :name => "Bernard Hinault" },
        { :place => "2", :name => "Greg Lemond" }
      ]
      table = Table.new(data)

      table.delete_column :place

      assert_equal 2, table.rows.size, "size"
      assert_equal({ :name => "Bernard Hinault" }, table.rows[0].to_hash)
      assert_equal({ :name => "Greg Lemond" }, table.rows[1].to_hash)
    end

    def test_strip
      data = [
        { :name => "  Bernard Hinault " }
      ]
      table = Table.new(data)

      assert_equal 1, table.rows.size, "size"
      assert_equal({ :name => "  Bernard Hinault " }, table.rows[0].to_hash)

      table.strip!

      assert_equal({ :name => "Bernard Hinault" }, table.rows[0].to_hash)
    end

    def test_to_space_delimited
      table = Table.new([
        [ "nom", "equipe", "homme", "age" ],
        [ "Hinault", "", "true", "30" ],
        [ "Lemond", "", "true", "20" ],
        [ "Hinault", "", "true", "30" ]
      ])

      expected = <<-END
nom       equipe   homme   age
Hinault            true    30 
Lemond             true    20 
Hinault            true    30 
END
      assert_equal expected, table.to_space_delimited
    end

    def test_autodetect_booleans
      data = [
        { :name => "Bernard Hinault", :member? => "0", :tdf_winner? => true },
        { :name => "Bob Roll", :member? => "1", :tdf_winner? => false },
      ]
      table = Table.new(data)
      assert_equal :string, table.columns[:name].column_type
      assert_equal :boolean, table.columns[:member?].column_type
      assert_equal :boolean, table.columns[:tdf_winner?].column_type
    end

    class StatelessTestMapper
      def self.map(array)
        Hash[*array]
      end
    end

    class TestMapper
      def map(array)
        Hash[*array]
      end
    end

    class TestColumnsMapper < ColumnMapper
      def map(key)
        _key = case key
        when "nom"
          :name
        when "equipe"
          :team
        when "homme"
          :homme?
        end

        super _key
      end
    end
  end
end
