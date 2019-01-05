# frozen_string_literal: true

module Tabular
  class ColumnMapper
    include Tabular::Blank

    # Convert +key+ to normalized symbol. Subclass for more complex mapping.
    def map(key)
      return nil if is_blank?(key)

      symbolize key
    end

    def symbolize(key)
      key.to_s.strip.gsub(/::/, "/")
         .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
         .gsub(/([a-z\d])([A-Z])/, '\1_\2')
         .tr("-", "_")
         .gsub(/ +/, "_")
         .delete(";")
         .downcase
         .to_sym
    rescue StandardError
      nil
    end
  end
end
