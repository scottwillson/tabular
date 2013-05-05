module Tabular
  class Renderer
    def self.render(column, row)
      row[column.key]
    end

    def self.render_header(column)
      column.to_s
    end
  end
end
