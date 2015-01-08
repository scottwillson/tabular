module Tabular
  # Simple Enumerable list of Hashes. Use Table.read(file_path) to read file. Can also create a Table with Table.new. Either
  # pass in data or set options and then call row=.
  class Table
    include Tabular::Blank
    include Tabular::Keys
    include Tabular::Tables::FileReading
    include Tabular::Zero

    attr_accessor :column_mapper
    attr_accessor :row_mapper
    attr_reader   :rows

    def self.read(file, options = {})
      table = Table.new
      table.read file, options[:as]
      table
    end

    # Pass data in as +rows+. Expects rows to be an Enumerable of Enumerables.
    # Maps rows to Hash-like Tabular::Rows.
    def initialize(rows = [])
      self.rows = rows
    end

    def rows
      @rows ||= []
    end

    # Set table rows. Calls row <<, which creates columns and links the source rows to Row#source.
    def rows=(source_rows = [])
      return [] unless source_rows

      source_rows.each do |row|
        self.<< row
      end

      rows
    end

    # Return Row at zero-based index, or nil if Row is out of bounds
    def [](index)
      rows[index]
    end

    # Add row to end of table. Create missing columns and link the source row to Row#source.
    # To control how source data is added to the Table, use Table#mapper= to set a class that
    # implements map(row) and returns a Hash.
    def <<(row)
      if row_mapper
        cells = row_mapper.map(row)
      else
        cells = row
      end

      if @columns.nil? || @columns.size == 0
        @columns = Tabular::Columns.new(self, cells, column_mapper)
        if !cells.respond_to?(:keys)
          return columns
        end
      end

      _row = Tabular::Row.new(self, cells, row)
      _row.keys.each do |key|
        columns << key
      end
      rows << _row
      _row
    end

    def inspect
      rows.map { |row| row.join(",") }.join("\n")
    end

    # Instance of Tabular::Columns
    def columns
      @columns ||= Tabular::Columns.new(self, [], column_mapper)
    end

    # Remove all columns that only contain a blank string, zero, or nil
    def delete_blank_columns!(*_options)
      exceptions = extract_exceptions(_options)

      (columns.map(&:key) - exceptions).each do |key|
        if rows.all? { |row| is_blank?(row[key]) || is_zero?(row[key]) }
          delete_column key
        end
      end
    end

    # Remove all columns that contain the same value in all rows
    def delete_homogenous_columns!(*_options)
      return if rows.size < 2

      exceptions = extract_exceptions(_options)

      (columns.map(&:key) - exceptions).each do |key|
        value = rows.first[key]
        if rows.all? { |row| row[key] == value }
          delete_column key
        end
      end
    end

    def delete_blank_rows!
      @rows = rows.reject(&:blank?)
      rows.each.with_index do |row, index|
        row.index = index
      end
    end

    # Remove preceding and trailing whitespace from all cells. By default, Table does not
    # strip whitespace from cells.
    def strip!
      rows.each do |row|
        columns.each do |column|
          value = row[column.key]
          if value.respond_to?(:strip)
            row[column.key] = value.strip
          elsif value.is_a?(Float)
            row[column.key] = strip_decimal(value)
          end
        end
      end
    end

    def delete_column(key)
      rows.each do |row|
        row.delete key
      end
      columns.delete key
    end

    # Set default Renderer. If present, will be used for all cells and Column headers.
    def renderer=(value)
      columns.renderer = value
    end

    # List of Renderers
    def renderers
      columns.renderers
    end

    def column_mapper=(mapper)
      if rows.nil? || rows.size == 0
        @columns = nil
      end
      @column_mapper = mapper
    end

    # Last-resort storage for client code data
    def metadata
      @metadata ||= {}
    end

    def to_space_delimited
      ([ columns ] + rows).map(&:to_space_delimited).join("\n") << "\n"
    end

    def to_s
      "#<#{self.class} #{rows.size}>"
    end


    private

    def extract_exceptions(options)
      if options.first && options.first[:except]
        options.first[:except]
      else
        []
      end
    end

    def strip_decimal(value)
      if value && value.to_i == value.to_f
        value.to_i
      else
        value
      end
    end
  end
end
