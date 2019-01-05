# frozen_string_literal: true

module Tabular
  module Zero
    def is_zero?(object) # rubocop:disable Naming/PredicateName
      return object.zero? if object.respond_to?(:zero?)

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
