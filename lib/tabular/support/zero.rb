class Object
  def zero?
    false
  end
end

class NilClass #:nodoc:
  def zero?
    false
  end
end

class FalseClass #:nodoc:
  def zero?
    false
  end
end

class TrueClass #:nodoc:
  def zero?
    false
  end
end

class String #:nodoc:
  def zero?
    self == "0" || self[/^0+\.0+$/]
  end
end
