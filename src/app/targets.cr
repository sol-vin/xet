module XET::App
  module Error
    abstract class Targets < XET::Error
      class NameAlreadyExists < Targets
      end
    end
  end
end

class XET::App::Targets
  @@targets_mutex = Mutex.new
  @@targets = {} of String => XET::App::Target

  def self.[](name)
    @@targets[name]
  end

  def self.[]?(name)
    @@targets[name]?
  end

  def self.add(target : XET::App::Target)
    @@targets_mutex.synchronize do
      if !(@@targets.keys.any? { |name| name == target.name })
        @@targets[target.name] = target
      else
        raise XET::App::Error::Targets::NameAlreadyExists
      end
    end
  end

  def self.add?(target : XET::App::Target)
    begin 
      add(target)
      true
    rescue e : XET::App::Error::Targets::NameAlreadyExists
      false
    end
  end

  def self.delete(name)
    @@targets_mutex.synchronize do
      @@targets.delete name
    end
  end
end