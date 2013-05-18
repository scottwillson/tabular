module Tabular
  # Simple Enumerable list of Hashes. Use Table.read(file_path) to read file. Can also create a Table with Table.new. Either
  # pass in data or set options and then call row=.
  class Table
    include Tabular::Blank
    include Tabular::Keys
    include Tabular::Zero

    attr_reader :options, :rows
    attr_accessor :row_mapper

    # +file+ : file path as String or File
    # Assumes .txt = tab-delimited, .csv = CSV, .xls = Excel. Assumes first row is the header.
    # Normalizes column names to lower-case with underscores.
    def self.read(file, *options)
      file_path = case file
      when File
         file.path
      else
        file
      end

      raise "Could not find '#{file_path}'" unless File.exists?(file_path)
      options = extract_options(options)

      format = self.format_from(options.delete(:as), file_path)
      data = read_file(file_path, format)

      Table.new data, options
    end

    # +format+ : :csv, :txt, or :xls
    # Returns Array of Arrays
    def self.read_file(file_path, format)
      case format
      when :xls
        require "spreadsheet"
        # Row#to_a coerces Excel data to Strings, but we want Dates and Numbers
        data = []
        Spreadsheet.open(file_path).worksheets.first.each do |excel_row|
          data << excel_row.inject([]) { |row, cell| row << cell; row }
        end
        data
      when :txt
        require "csv"
        if RUBY_VERSION < "1.9"
          ::CSV.open(file_path, "r", "\t").collect { |row| row }
        else
          CSV.read(file_path, :col_sep => "\t")
        end
      when :csv
        if RUBY_VERSION < "1.9"
          require "fastercsv"
          FasterCSV.read(file_path)
        else
          require "csv"
          CSV.read(file_path)
        end
      else
        raise "Cannot read '#{format}' format. Expected :xls, :xlsx, :txt, or :csv"
      end
    end

    # Pass data in as +rows+. Expects rows to be an Enumerable of Enumerables.
    # Maps rows to Hash-like Tabular::Rows.
    #
    # Options:
    # :columns => { :original_name => :preferred_name, :column_name => { :column_type => :boolean } }
    #
    # The :columns option will likely be deprecated and options for mappers and renderers added
    def initialize(rows = [], *options)
      @options = Table.extract_options(options)
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

      if @columns.nil? && !cells.respond_to?(:keys)
        @columns = Tabular::Columns.new(self, cells, options[:columns])
        return columns
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
      @columns ||= Tabular::Columns.new(self, [])
    end

    # Remove all columns that only contain a blank string, zero, or nil
    def delete_blank_columns!
      columns.map(&:key).each do |key|
        if rows.all? { |row| is_blank?(row[key]) || is_zero?(row[key]) }
          delete_column key
        end
      end
    end
    
    # Remove all columns that contain the same value in all rows
    def delete_homogenous_columns!
      return if rows.size < 2
      
      columns.map(&:key).each do |key|
        value = rows.first[key]
        if rows.all? { |row| row[key] == value }
          delete_column key
        end
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

    def to_s
      "#<#{self.class} #{rows.size}>"
    end


    private

    def self.extract_options(options)
      if options
        options.flatten.first || {}
      else
        {}
      end
    end

    def self.format_from(as_option, file_path)
      if as_option
        as_option
      else
        case File.extname(file_path)
        when ".xls", ".xlsx"
          :xls
        when ".txt"
          :txt
        when ".csv"
          :csv
        end
      end
    end
  end
end
