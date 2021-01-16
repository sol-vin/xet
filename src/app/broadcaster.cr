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
    @socket = XET::Socket::UDP.new(XET::App.broadcast_ip, @port)
    @socket.bind ::Socket::IPAddress.new(XET::App.server_ip, @port.to_i32)
    Log.info {"Bound to interface #{ARGV[1]} @ #{XET::App.server_ip} on #{@port}"}
    @socket.broadcast = true
  end

  def refresh_socket
    @socket.close
    @socket = XET::Socket::UDP.new(XET::App.broadcast_ip, @port)
    @socket.bind ::Socket::IPAddress.new(XET::App.server_ip, @port.to_i32)
    Log.info {"Bound to interface #{ARGV[1]} @ #{XET::App.server_ip} on #{@port}"}
    @socket.broadcast = true
  end

  def is_listening?
    !@incoming_netcom.closed?
  end

  def start_listening
    if @incoming_netcom.closed?
      Log.info { "Starting listening on #{port}" }
      @incoming_netcom = Channel(XET::Command::Network::Common::Reply).new
      _spawn_listen_fiber
    else
      raise XET::App::Error::Broadcaster::AlreadyListening.new
    end
  end

  def stop_listening
    unless @incoming_netcom.closed?
      Log.info { "Stopping listening on #{port}" }
      @incoming_netcom.close
    end
  end

  def listen?
    @incoming_netcom.receive?
  end

  private def _spawn_listen_fiber
    spawn(name: "XET::App::Broadcaster -> Listen Fiber") do
      until @incoming_netcom.closed?
        begin
          xmsg = @socket.receive_message
          Log.info { "Got a potential reply from #{xmsg.message}" }
          netcom_reply = XET::Command::Network::Common::Reply.from_msg(xmsg)
          Log.info { "Got parsed reply from #{netcom_reply.message}" }
          spawn(name: "XET::App::Broadcaster -> Listen Fiber -> Sending NetCom Result") do
            begin
              @incoming_netcom.send netcom_reply
            rescue e : Channel::ClosedError
            end
          end
        rescue exception : XET::Error::Command::CannotParse
          Log.info { "Couldn't parse message" }
        rescue exception : XET::Error::Receive::Timeout
          Log.info { "Recieved a timeout" }
        rescue exception : XET::Error::Receive
          if exception.is_a?(XET::Error::Receive::Timeout)
          else
            Log.info { "Listener on #{@port} had an exception: #{exception}" }
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
      raise XET::App::Error::Broadcaster::AlreadyBroadcasting.new
    end
  end

  def stop_broadcasting
    @broadcasting = false
  end

  private def _spawn_broadcast_fiber
    spawn(name: "XET::App::Broadcaster -> Broadcast Fiber") do
      while @broadcasting
        spawn(name: "XET::App::Broadcaster -> Listen Fiber -> Sending NetCom Result") do
          begin
            @socket.send_message XET::Command::Network::Common::Request.new
          rescue e : XET::Error::Send
            Log.error {"Broadcaster on #{@port} had an exception: #{e}"}
          end
        end
        sleep @interval
      end
    end
  end
end
