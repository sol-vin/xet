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

  module Filter
    alias FilterType = (String | Regex)

    class Camera
      property? target_all = false
      property names = [] of FilterType
      property serial_numbers = [] of FilterType
      property mac_addresses = [] of FilterType
      property ip_addresses = [] of FilterType

      def empty?
        names.empty? && serial_numbers.empty? && mac_addresses.empty? && ip_addresses.empty?
      end
    end

    class Client
      property? target_all = false
      property ip_addresses = [] of FilterType

      def empty?
        ip_addresses.empty?
      end
    end
  end

  @netcom_request_channel = Channel(::Socket::IPAddress).new
  @netcom_reply_channel = Channel(XET::Command::Network::Common::Reply).new

  property clients_filter : Filter::Client = Filter::Client.new
  property cameras_filter : Filter::Camera = Filter::Camera.new

  @discovery_socket : XET::Socket::UDP

  getter port : UInt16

  def initialize(@port = XET::DEFAULT_DISCOVERY_PORT)
    @discovery_socket = XET::Socket::UDP.new(XET::App.broadcast_ip, @port)
    refresh_socket
    stop
    Log.info { "ProxyHandler: Bound to #{XET::App.server_ip} on #{@port}" }
  end

  private def make_netcom_reply_hash(netcom_reply : XET::Command::Network::Common::Reply) : UInt64
    netcom_reply.config.host_ip.as(::Socket::IPAddress).address.hash &+ netcom_reply.config.mac.as(String).hash
  end

  def refresh_socket
    @discovery_socket = XET::Socket::UDP.new(XET::App.broadcast_ip, @port)
    @discovery_socket.bind ::Socket::IPAddress.new(XET::App.server_ip, @port.to_i32)
    @discovery_socket.broadcast = true
    
    @netcom_request_channel = Channel(::Socket::IPAddress).new
    @netcom_reply_channel = Channel(XET::Command::Network::Common::Reply).new
  end

  def start
    if @discovery_socket.closed?
      refresh_socket
      Log.info { "ProxyHandler: Starting listening on #{port}" }
      _spawn_discovery_fiber
      _spawn_main_fiber
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
              @netcom_request_channel.send incoming_ip 
            end
          elsif xmsg.id == XET::Command::Network::Common::Reply::ID
            if netcom_reply = XET::Command::Network::Common::Reply.from_msg?(xmsg)
              @netcom_reply_channel.send netcom_reply 
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
    _spawn_clients_fiber
    _spawn_cameras_fiber
  end

  private def _spawn_clients_fiber
    spawn(name: "XET::App::ProxyHandler -> Client Fiber") do
      until @netcom_request_channel.closed?
        begin
          client_ip_address = @netcom_request_channel.receive

          if !clients_filter.empty? || clients_filter.target_all?
            passes_filter = clients_filter.target_all? || (clients_filter.ip_addresses.any? do |filter_type_item|
              if filter_type_item.class == String
                filter_type_item.as(String) == client_ip_address.address
              else
                !!(client_ip_address.address =~ filter_type_item.as(Regex))
              end
            end)
            Log.info { "#{Fiber.current.name}: Potential client detected @ #{client_ip_address.address}" }
            if passes_filter
              Log.info { "#{Fiber.current.name}: Client detected that passes the filter @ #{client_ip_address.address}" }
            end
          end
        rescue Channel::ClosedError
        end
      end
    end
  end

  private def _spawn_cameras_fiber
    spawn(name: "XET::App::ProxyHandler -> Camera Fiber") do
      until @netcom_reply_channel.closed?
        begin
          netcom_reply = @netcom_reply_channel.receive

          if !cameras_filter.empty? || cameras_filter.target_all?
            matches_name = (cameras_filter.names.any? do |filter_type_item|
              if filter_type_item.class == String
                filter_type_item.as(String) == netcom_reply.config.hostname
              else
                !!(netcom_reply.config.hostname.to_s =~ filter_type_item.as(Regex))
              end
            end)

            matches_serial_number = (cameras_filter.serial_numbers.any? do |filter_type_item|
              if filter_type_item.class == String
                filter_type_item.as(String) == netcom_reply.config.serial_number
              else
                !!(netcom_reply.config.serial_number.to_s =~ filter_type_item.as(Regex))
              end
            end)

            matches_ip_address = (cameras_filter.ip_addresses.any? do |filter_type_item|
              if filter_type_item.class == String
                filter_type_item.as(String) == netcom_reply.config.host_ip.try(&.address)
              else
                !!(netcom_reply.config.host_ip.try(&.address).to_s =~ filter_type_item.as(Regex))
              end
            end)

            
            matches_mac_address = (cameras_filter.mac_addresses.any? do |filter_type_item|
              if filter_type_item.class == String
                filter_type_item.as(String) == netcom_reply.config.mac
              else
                !!(netcom_reply.config.mac.to_s =~ filter_type_item.as(Regex))
              end
            end)

            passes_filter = cameras_filter.target_all? || matches_name || matches_serial_number || matches_ip_address || matches_mac_address
            Log.info { "#{Fiber.current.name}: Potential camera detected @ #{netcom_reply.config.host_ip}" }
            if passes_filter
              Log.info { "#{Fiber.current.name}: Camera detected that passes the filter @ #{netcom_reply.config.host_ip}" }
            end
          end
        rescue Channel::ClosedError
        end
      end
    end
  end

  def stop
    @discovery_socket.close
    @netcom_request_channel.close
    @netcom_reply_channel.close
  end

  def is_running?
    !@discovery_socket.closed?
  end
end
