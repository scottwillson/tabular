module Tabular
  # Don't mess with Object
  module Blank
    def is_blank?(object)
      case object
      when NilClass
        true
      when FalseClass
        true
      when TrueClass
        true
      when String
        object !~ /\S/
      when Numeric
        false
      else
        object.respond_to?(:empty?) ? object.empty? : !object
      end
    end
  end
end
