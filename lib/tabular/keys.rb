module Tabular
  module Keys
    def key_to_sym(key)
      _key = case key
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
