module Tabular
  class Column
    attr_reader :key, :column_type

    # +table+ -- parent Table
    # +column+ -- parent Columns
    # +key+ is normalized to a downcase, underscored symbol
    def initialize(table, columns, key = nil, columns_map = {})
      @columns = columns
      @table = table

      key = symbolize(key)
      columns_map = columns_map || {}
      map_for_key = columns_map[key]

      @column_type = :string
      case map_for_key
      when nil
        @key = key
        @column_type = :date if key == :date
      when Symbol
        @key = map_for_key
        @column_type = :date if key == :date
      when Hash
        @key = key
        @column_type = map_for_key[:column_type]
      else
        raise "Expected Symbol or Hash, but was #{map_for_key.class}"
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
      @precision || cells.map(&:to_f).map {|n| n.round(3) }.map {|n| n.to_s.split(".").last.gsub(/0+$/, "").length }.max
    end

    # Human-friendly header string. Delegate to +renderer+'s render_header method.
    def render
      renderer.render_header self
    end

    # Renderer
    def renderer
      @columns.renderer(key)
    end

    def inspect
      "#<Tabular::Column #{key} #{column_type}>"
    end

    def to_s
      key.to_s
    end
    
    private

    def symbolize(key)
      return nil if key.blank?

      begin
        key.to_s.strip.gsub(/::/, '/').
          gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
          gsub(/([a-z\d])([A-Z])/,'\1_\2').
          tr("-", "_").
          gsub(/ +/, "_").
          downcase.
          to_sym
      rescue
        nil
      end
    end
  end
end
