module Tabular
  module Zero
    def is_zero?(object)
      if object.respond_to?(:zero?)
        return object.zero?
      end
  
      case object
      when NilClass, FalseClass, TrueClass
        false
      when String
        object == "0" || object[/^0+\.0+$/]
      else
        false
      end
    end
  end
end
