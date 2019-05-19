# frozen_string_literal: true

module Tabular
  # The Table's header: a list of Columns.
  class Columns
    include Enumerable
    include Tabular::Blank
    include Tabular::Keys

    attr_writer :column_mapper
    attr_writer :renderer

    # +table+ -- Table
    # +data+ -- array of header names

    def column_mapper
      @column_mapper ||= Tabular::ColumnMapper.new
    end

    def initialize(table = Table.new, names = [], column_mapper = nil)
      @table = table
      @renderer = nil
      self.column_mapper = column_mapper

      @column_indexes = {}
      @columns_by_key = {}

      set_columns table, names
    end

    def set_columns(table = Table.new, names = [])
      index = 0

      names = names.keys if names.respond_to?(:keys)

      @columns = names.map do |name|
        new_column = Tabular::Column.new(table, self, name)
        unless is_blank?(new_column.key)
          @column_indexes[new_column.key] = index
          @columns_by_key[new_column.key] = new_column
        end
        index += 1
        new_column
      end
    end

    def empty?
      size.zero?
    end

    # Deprecated
    def has_key?(key) # rubocop:disable Naming/PredicateName
      key? key
    end

    # Is the a Column with this key? Keys are lower-case, underscore symbols.
    # Example: :postal_code
    def key?(key)
      @columns.any? { |column| column.key == key }
    end

    # Column for +key+
    def [](key)
      @columns_by_key[key_to_sym(key)]
    end

    # Zero-based index of Column for +key+
    def index(key)
      @column_indexes[key]
    end

    # Call +block+ for each Column
    def each(&block)
      @columns.each(&block)
    end

    # Add a new Column with +key+
    def <<(key)
      column = Column.new(@table, self, key)
      return if is_blank?(column.key) || key?(key)

      @column_indexes[column.key] = @columns.size
      @column_indexes[@columns.size] = column
      @columns_by_key[column.key] = column
      @columns << column
    end

    def delete(key)
      @columns.delete_if { |column| column.key == key }
      @columns_by_key.delete key
      @column_indexes.delete key

      @columns.each.with_index do |column, index|
        @column_indexes[column.key] = index
      end
    end

    # Count of Columns#columns
    def size
      @columns.size
    end

    # Renderer for Column +key+. Default to Table#Renderer.
    def renderer(key)
      renderers[key] || @renderer || Renderer
    end

    # List of Renderers
    def renderers
      @renderers ||= {}
    end

    def to_space_delimited
      map(&:to_space_delimited).join "   "
    end
  end
end
