module XET::App
  module Error
    abstract class ProxyHandler < XET::Error
      class AlreadyListening < ProxyHandler
      end
    end
  end
end

class XET::App::ProxyHandler
  # What needs to happen:
  # Client sends out broadcast Network::Common::Request
  # Cameras send out broadcast Network::Common::Reply
  # Run all replies through a filter(ip, mac, sn, etc)
  # Save all Network::Common::Reply that passes the filter to an array after altering each one with the proper data where needed
  # Send out DoS to each camera
  # Create a MITM server for each camera (see if we can modify the ports for tcp, udp, etc)
  # Spam modified Network::Common::Reply to client for all spoofed cameras
  # Hijack credentials

  class Filter
    property names = [] of String
    property serial_numbers = [] of String
    property mac_addresses = [] of String
    property ip_addresses = [] of String
  end

  @clients_mutex : Mutex = Mutex.new
  @clients : Array(String) = [] of String
  @cameras_mutex : Mutex = Mutex.new
  @cameras = {} of UInt64 => XET::Command::Network::Common::Reply

  property filter : Filter = Filter.new

  @discovery_socket : XET::Socket::UDP

  getter port : UInt16

  def initialize(@port = XET::DEFAULT_DISCOVERY_PORT)
    @discovery_socket = XET::Socket::UDP.new(XET::App.broadcast_ip, @port)
    @discovery_socket.bind ::Socket::IPAddress.new(XET::App.server_ip, @port.to_i32)
    @discovery_socket.broadcast = true
    @discovery_socket.close
    Log.info {"ProxyHandler: Bound to #{XET::App.server_ip} on #{@port}"}
  end

  private def make_netcom_reply_hash(netcom_reply : XET::Command::Network::Common::Reply) : UInt64
    netcom_reply.config.host_ip.as(::Socket::IPAddress).address.hash &+ netcom_reply.config.mac.as(String).hash
  end

  def refresh_socket
    @discovery_socket = XET::Socket::UDP.new(XET::App.broadcast_ip, @port)
    @discovery_socket.bind ::Socket::IPAddress.new(XET::App.server_ip, @port.to_i32)
    @discovery_socket.broadcast = true
  end

  def start
    if @discovery_socket.closed?
      refresh_socket
      Log.info { "ProxyHandler: Starting listening on #{port}" }
      _spawn_discovery_fiber

    else
      raise XET::App::Error::ProxyHandler::AlreadyListening.new
    end
  end

  private def _spawn_discovery_fiber
    spawn(name: "XET::App::ProxyHandler -> Listen Fiber") do
      until @discovery_socket.closed?
        begin
          ip_and_msg = @discovery_socket.receive_message
          incoming_ip, xmsg = ip_and_msg[1], ip_and_msg[0]
          if xmsg.id == XET::Command::Network::Common::Request::ID
            if netcom_request = XET::Command::Network::Common::Request.from_msg?(xmsg)
              @clients_mutex.synchronize do
                unless @clients.any? {|c| c == incoming_ip.address}
                  @clients << incoming_ip.address
                  Log.info {"#{Fiber.current.name}: Got new Client #{incoming_ip.address}"}
                end
              end
            else
              
            end
          elsif xmsg.id == XET::Command::Network::Common::Reply::ID
            if netcom_reply = XET::Command::Network::Common::Reply.from_msg?(xmsg)
              raise XET::Error::Command::CannotParse.new("Netcom reply had no ip or mac") if netcom_reply.config.host_ip.nil? && netcom_reply.config.mac.nil?
              netcom_hash = make_netcom_reply_hash(netcom_reply)
              @cameras_mutex.synchronize do
                unless @cameras[netcom_hash]?
                  @cameras[netcom_hash] = netcom_reply
                  Log.info {"#{Fiber.current.name}: Got new Camera #{incoming_ip.address}"}
                end
              end
            end
          end
        rescue e : XET::Error::Command::CannotParse
         # Log.info { "#{Fiber.current.name}: Couldn't parse message - #{e}" }
        rescue e : XET::Error::Receive::Timeout
        rescue e : XET::Error::Receive
          if e.is_a?(XET::Error::Receive::Timeout)
          else
            Log.info { "#{Fiber.current.name}: Listener on #{@port} had an exception: #{e}" }
          end
        rescue e : XET::Error::Socket::Closed
          # Socket closed so do nothing to gracefull exit
        end
      end
    end
  end

  private def _spawn_main_fiber
    spawn(name: "XET::App::ProxyHandler -> Main Fiber") do
      until @discovery_socket.closed?
        
      end
    end
  end

  def stop
    @discovery_socket.close
  end

  def is_running?
    !@discovery_socket.close
  end


end