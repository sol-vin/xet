module XET::App
  module Error
    abstract class FoundDevices < XET::Error
      class IPAlreadyExists < FoundDevices
      end
    end
  end
end

class XET::App::FoundDevices
  @@found_devices_mutex = Mutex.new

  #TODO: Fix this when it's time to implement custom JSON parsers
  @@found_devices = {} of String => XET::Command::Network::Common::Reply

  def self.[](host_ip)
    @@found_devices_mutex.synchronize do
      @@found_devices[host_ip]
    end
  end

  def self.[]=(host_ip : String, other : XET::Command::Network::Common::Reply)
    @@found_devices_mutex.synchronize do
      @@found_devices[host_ip] = other
    end
  end

  def self.[]?(host_ip : String)
    @@found_devices_mutex.synchronize do
      @@found_devices[host_ip]?
    end
  end

  def self.dup
    @@found_devices_mutex.synchronize do
      @@found_devices.dup
    end
  end

  def self.size
    size = 0
    @@found_devices_mutex.synchronize do
     size = @@found_devices.size
    end
    size
  end

  def self.add(net_com_reply : XET::Command::Network::Common::Reply)
    @@found_devices_mutex.synchronize do
      address = net_com_reply.config.try(&.host_ip).try(&.address)
      if address && !(@@found_devices.keys.any? { |host_ip| host_ip == address})
        @@found_devices[address] = net_com_reply
        Log.info { "Found device #{address}" }
      else
        raise XET::App::Error::FoundDevices::IPAlreadyExists.new
      end
    end
  end

  def self.add?(net_com_reply : XET::Command::Network::Common::Reply)
    begin
      add(net_com_reply)
      true
    rescue e : XET::App::Error::FoundDevices::IPAlreadyExists
      false
    end
  end

  def self.delete(host_ip)
    @@found_devices_mutex.synchronize do
      @@found_devices.delete host_ip
    end
  end
end