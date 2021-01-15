module XET::App
  module Error
    abstract class Broadcasters < XET::Error
      class PortAlreadyExists < Broadcasters
      end
    end
  end
end

class XET::App::Broadcasters
  @@broadcasters_mutex = Mutex.new
  @@broadcasters = {} of UInt32 => XET::App::Broadcaster

  def self.[](name)
    @@broadcasters[name]
  end

  def self.[]?(name)
    @@broadcasters[name]?
  end

  def self.add(broadcaster : XET::App::Broadcaster)
    @@broadcasters_mutex.synchronize do
      if !(@@broadcasters.keys.any? { |broadcaster| port == broadcaster.port })
        @@broadcasters[broadcaster.port] = broadcaster
      else
        raise XET::App::Error::Broadcasters::NameAlreadyExists
      end
    end
  end

  def self.add?(broadcaster : XET::App::Broadcaster)
    begin 
      add(broadcaster)
      true
    rescue e : XET::App::Error::Broadcasters::NameAlreadyExists
      false
    end
  end

  def self.delete(port)
    @@broadcasters_mutex.synchronize do
      @@broadcasters.delete port
    end
  end
end