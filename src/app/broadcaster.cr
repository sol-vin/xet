module XET::App
  module Error
    abstract class Broadcaster < XET::Error
      class AlreadyListening < Broadcaster
      end

      class AlreadyBroadcasting < Broadcaster
      end
    end
  end
end

class XET::App::Broadcaster
  @incoming_netcom = Channel(XET::Command::Network::Common::Reply).new

  getter port : UInt16

  def initialize(@port = XET::DEFAULT_DISCOVERY_PORT, @interval = 20)
    @incoming_netcom.close
    @socket = XET::Socket::UDP.new("255.255.255.255", @port)
    @socket.bind ::Socket::IPAddress.new("0.0.0.0", @port.to_i32)
    @socket.broadcast = true
  end

  def refresh_socket
    @socket.close
    @socket = XET::Socket::UDP.new("255.255.255.255", @port)
    @socket.bind ::Socket::IPAddress.new("0.0.0.0", @port.to_i32)
    @socket.broadcast = true
  end

  def is_listening?
    @incoming_netcom.closed?
  end

  def start_listening
    if @incoming_netcom.closed?
      @incoming_netcom = Channel(XET::Command::Network::Common::Reply).new
      _spawn_listen_fiber
    else
      raise XET::App::Error::Broadcaster::AlreadyListening
    end
  end

  def stop_listening
    @incoming_netcom.close
  end

  def listen?
    @incoming_netcom.receive?
  end

  private def _spawn_listen_fiber
    spawn(name: "XET::App::Broadcaster -> Listen Fiber") do
      until @incoming_netcom.closed?
        begin
          xmsg = @socket.receive_message
          netcom_reply = XET::Command::Network::Common::Reply.from_msg(xmsg)
          spawn(name: "XET::App::Broadcaster -> Listen Fiber -> Sending NetCom Result") do
            begin
              @incoming_netcom.send netcom_reply
            rescue e : Channel::ClosedError
            end
          end
        rescue exception : XET::Error::Command::CannotParse
          # Ignore
        rescue exception : XET::Error::Receive::Timeout
          # Ignore
        rescue exception : XET::Error::Receive
          if exception.is_a?(XET::Error::Receive::Timeout)
          else
            LOG.error("Listener on #{@port} had an exception: #{exception}")
          end
        end
      end
    end
  end

  @broadcasting = false

  def is_broadcasting?
    @broadcasting
  end

  def start_broadcasting
    if !@broadcasting
      @broadcasting = true
      _spawn_broadcast_fiber
    else
      raise XET::App::Error::Broadcaster::AlreadyBroadcasting
    end
  end

  def stop_broadcasting
    @broadcasting = false
  end

  private def _spawn_broadcast_fiber
    spawn("XET::App::Broadcaster -> Broadcast Fiber") do
      while @broadcasting
        sleep @interval
        spawn(name: "XET::App::Broadcaster -> Listen Fiber -> Sending NetCom Result") do
          begin
            @socket.send_message XET::Command::Network::Common::Request.new
          rescue e : XET::Error::Send
            LOG.error("Broadcaster on #{@port} had an exception: #{exception}")
          end
        end
      end
    end
  end
end
