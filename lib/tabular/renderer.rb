# frozen_string_literal: true

module Tabular
  # Custom display of cells. By default, return to_s.
  #
  # Create your own Renders by implementing a class that responds to render(column, row) for cells
  # and/or render_header(column) for Column headers.
  class Renderer
    def self.render(column, row)
      row[column.key]
    end

    def self.render_header(column)
      column.to_s
    end
  end
end
