class XET::Message
  macro inherited
    XET::Commands << {{@type}}
  end
end

module XET::Commands
  @@a = {} of String => XET::Message.class
  def self.<<(other : XET::Message.class)
    @@a[other.to_s] = other
  end

  def self.[](klass_name : String)
    @@a[klass_name]
  end

  def self.[]?(klass_name : String)
    @@a[klass_name]?
  end

  def self.to_h
    @@a.dup
  end

  def self.each(&block)
    @@a.each &block
  end
end