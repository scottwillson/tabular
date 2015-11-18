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
      unless @hash
        @hash = Hash.new
        columns.each do |column|
          index = columns.index(column.key)
          if index
            case column.column_type
            when :boolean
              @hash[column.key] = [1, "1", true, "true"].include?(@array[index])
            when :date
              if @array[index].is_a?(Date) || @array[index].is_a?(DateTime) || @array[index].is_a?(Time)
                @hash[column.key] = @array[index]
              else
                begin
                  if @array[index]
                    @hash[column.key] = Date.parse(@array[index].to_s, true)
                  else
                    @hash[column.key] = nil
                  end
                rescue ArgumentError
                  date = parse_invalid_date(@array[index])
                  if date
                    @hash[column.key] = date
                  else
                    raise ArgumentError, "'#{column.key}' index #{index} #{@array[index]}' is not a valid date"
                  end
                end
              end
            else
              @hash[column.key] = @array[index]
            end
          end
        end
      end
      @hash
    end


    private

    # Handle common m/d/yy case that Date.parse dislikes
    def parse_invalid_date(value)
      return unless value

      parts = value.to_s.split("/")
      return unless parts.size == 3

      month = parts[0].to_i
      day = parts[1].to_i
      year = parts[2].to_i
      return unless month >=1 && month <= 12 && day >= 1 && day <= 31

      if year == 0
        year = 2000
      elsif year > 0 && year < 69
        year = 2000 + year
      elsif year > 69 && year < 100
        year = 1900 + year
      elsif year < 1900 || year > 2050
        return nil
      end

      Date.new(year, month, day)
    end
  end
end
