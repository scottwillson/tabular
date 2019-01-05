# frozen_string_literal: true

module Tabular
  module Keys
    # Return Symbol for +key+. Translate Column and String. Return +key+ unmodified for anything else.
    def key_to_sym(key)
      case key
      when Column
        key.key
      when String
        key.to_sym
      else
        key
      end
    end
  end
end
