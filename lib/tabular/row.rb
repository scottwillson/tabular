require "date"

module Tabular
  # Associate list of cells. Each Table has a list of Rows. Access Row cells via symbols. Ex: row[:city]
  class Row
    include Enumerable
    include Tabular::Blank
    include Tabular::Keys

    attr_accessor :index
    attr_reader :source

    # +table+ -- Table
    # +cells+ -- array (not neccessarily Strings)
    # +source+ -- original data before mapped to Hash or Array (optional)
    def initialize(table, cells = [], source = nil)
      @table = table
      @source = source || cells

      if cells.respond_to?(:keys)
        @array = cells.values
        @hash = {}
        cells.each do |key, value|
          @hash[key_to_sym(key)] = value
        end
      else
        @array = cells
        @hash = nil
      end

      @index = table.rows.size
    end

    # Cell value by symbol. E.g., row[:phone_number]
    def [](key)
      hash[key]
    end

    # Set cell value. Adds cell to end of Row and adds new Column if there is no Column for +key_
    def []=(key, value)
      if columns.has_key?(key)
        @array[columns.index(key)] = value
      else
        @array << value
        columns << key
      end
      hash[key] = value
    end

    # Call +block+ for each cell
    def each(&block)
      @array.each(&block)
    end

    # Call +block+ for each cell
    def each_with_key(&block)
      hash.each(&block)
    end

    # Keys for all columns
    def keys
      hash.keys
    end

    # For pretty-printing cell values
    def join(sep = nil)
      @array.join(sep)
    end

    def delete(key)
      @array.delete key
      hash.delete key
    end

    # Previous Row
    def previous
      if index > 0
        @table.rows[index - 1]
      end
    end

    # Next Row
    def next
      @table.rows[index + 1]
    end

    # Is this the last row?
    def last?
      index == @table.rows.size - 1
    end

    def blank?
      @array.all? { |cell| is_blank?(cell) }
    end

    # Tabluar::Columns
    def columns
      @table.columns
    end

    # By default, return self[key]. Customize by setting Table#renderer or Column#renderers[key]
    def render(key)
      column = columns[key]
      column.renderer.render column, self
    end

    def metadata
      @table.metadata
    end

    def to_hash
      hash.dup
    end

    def to_space_delimited
      _cells = []

      hash.each do |key, _|
        _cells << (render(key) || "").ljust(columns[key].width)
      end

      _cells.join "   "
    end

    def inspect
      hash.inspect
    end

    def to_s
      @array.join(", ").to_s
    end


    protected

    def hash #:nodoc:
      @hash ||= build_hash
    end

    def build_hash #:nodoc:
      _hash = Hash.new
      columns.each do |column|
        _hash[column.key] = value_for_hash(column)
      end
      _hash
    end

    def value_for_hash(column) #:nodoc:
      index = columns.index(column.key)
      return nil unless index

      value = @array[index]

      case column.column_type
      when :boolean
        [ 1, "1", true, "true" ].include?(value)
      when :date
        if date?(value)
          value
        else
          parse_date value, column.key, index
        end
      else
        value
      end
    end


    private

    def date?(value)
      value.is_a?(Date) || value.is_a?(DateTime) || value.is_a?(Time)
    end

    def parse_date(value, key, index)
      return nil unless value

      begin
        Date.parse(value.to_s, true)
      rescue ArgumentError
        date = parse_invalid_date(value)
        if date
          date
        else
          raise ArgumentError, "'#{key}' index #{index} #{value}' is not a valid date"
        end
      end
    end

    # Handle common m/d/yy case that Date.parse dislikes
    def parse_invalid_date(value)
      return unless value

      parts = value.to_s.split("/")
      return unless parts.size == 3

      month = parts[0].to_i
      day = parts[1].to_i
      year = parts[2].to_i
      return unless month >= 1 && month <= 12 && day >= 1 && day <= 31

      year = add_century_to(year)

      Date.new(year, month, day)
    end

    def add_century_to(year)
      if year >= 0 && year < 69
        2000 + year
      elsif year > 69 && year < 100
        1900 + year
      elsif year < 1900 || year > 2050
        nil
      else
        year
      end
    end
  end
end
