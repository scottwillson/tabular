# frozen_string_literal: true

module Tabular
  module Tables
    module FileReading
      # +file+ : file path as String or File
      # Assumes .txt = tab-delimited, .csv = CSV, .xls = Excel. Assumes first row is the header.
      # Normalizes column names to lower-case with underscores.
      # +format+ : :csv, :txt, or :xls
      # +sheet+: integer, specifies the desired worksheet of an .xls/xlsx file, 0 by default.
      # Returns Array of Arrays
      def read(file, format = nil, sheet = nil)
        file_path = to_file_path(file)
        format ||= format_from(format, file_path)

        self.rows = case format
                    when :xls, :xlsx
                      # Set to first sheet if undefined.
                      sheet ||= 0
                      read_spreadsheet file_path, format, sheet
                    when :txt
                      read_txt file_path
                    when :csv
                      read_csv file_path
                    else
                      raise "Cannot read '#{format}' format. Expected :xls, :xlsx, :txt, or :csv"
                    end
      end

      def format_from(as_option, file_path)
        as_option || case File.extname(file_path)
                     when ".xls"
                       :xls
                     when ".xlsx"
                       :xlsx
                     when ".txt"
                       :txt
                     when ".csv"
                       :csv
                     end
      end

      def to_file_path(file)
        file_path = case file
                    when File
                      file.path
                    else
                      file
                    end

        raise "Could not find '#{file_path}'" unless File.exist?(file_path)

        file_path
      end

      def read_spreadsheet(file_path, format, sheet)
        require "roo"

        if format == :xls
          require "roo-xls"
          excel = ::Roo::Excel.new(file_path)
        else
          excel = ::Roo::Excelx.new(file_path)
        end

        # Row#to_a coerces Excel data to Strings, but we want Dates and Numbers
        data = []
        excel.sheet(sheet).each do |excel_row|
          data << excel_row.each_with_object([]) { |cell, row| row << cell; }
        end
        data
      end

      def read_txt(file_path)
        require "csv"
        if RUBY_VERSION < "1.9"
          ::CSV.open file_path, "r", "\t"
        else
          CSV.read file_path, col_sep: "\t"
        end
      end

      def read_csv(file_path)
        if RUBY_VERSION < "1.9"
          require "fastercsv"
          FasterCSV.read file_path
        else
          require "csv"
          CSV.read file_path
        end
      end
    end
  end
end
