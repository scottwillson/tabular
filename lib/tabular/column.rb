# frozen_string_literal: true

module Tabular
  class Column
    attr_reader :key, :column_type

    # +table+ -- parent Table
    # +column+ -- parent Columns
    # +key+ should be a normalized, downcase, underscored symbol
    def initialize(table, columns, key = nil)
      @columns = columns
      @table = table
      @key = self.columns.column_mapper.map(key)

      @column_type = if @key && @key.to_s["date"]
                       :date
                     elsif @key && @key.to_s[/\?\z/]
                       :boolean
                     else
                       :string
                     end
    end

    def rows
      @table.rows
    end

    # All cells value under this Column
    def cells
      rows.map { |r| r[key] }
    end

    # Maximum value for cells in the Column. Determine with Ruby #max
    def max
      cells.compact.max
    end

    # Number of zeros to the right of the decimal point. Useful for formtting time data.
    def precision
      @precision ||= cells.map(&:to_f).map { |n| n.round(3) }.map { |n| n.to_s.split(".").last.gsub(/0+$/, "").length }.max
    end

    # Widest string in column
    def width
      @width ||= (cells.map(&:to_s) << to_s).map(&:size).max
    end

    # Human-friendly header string. Delegate to +renderer+'s render_header method.
    def render
      renderer.render_header self
    end

    # Renderer
    def renderer
      @columns.renderer(key)
    end

    def to_space_delimited
      to_s.ljust width
    end

    def inspect
      "#<Tabular::Column #{key} #{column_type}>"
    end

    def to_s
      key.to_s
    end

    protected

    def columns
      @columns ||= Columns.new
    end
  end
end
