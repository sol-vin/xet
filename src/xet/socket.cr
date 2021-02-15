module ::XET::Socket
  getter target : ::Socket::IPAddress? = nil

  def set_target(socket_ip : ::Socket::IPAddress)
    @target = socket_ip
  end

  # Target a camera.
  def set_target(ip : String, port = 0)
    @target = ::Socket::IPAddress.new(ip, port.to_i32)
  end
  
  # Have we found at least one target yet?
  def has_target?
    @target.port != 0
  end

  def login(username = "admin", password = "", encryption_type = "MD5")
    begin
      self.send_message(XET::Command::Bits::Request.new(
        session_id: XET::Command::Bits::Request::SPECIAL_SESSION_ID,
        bits: 0,
        data_encryption_type: XET::Command::Bits::Request::DataEncryptionType.new(
          aes: false
        ),
        aes: false,
        encryption_algo: "",
        login_encryption_type: XET::Command::Bits::Request::LoginEncryptionType.new(
          md5: encryption_type == "MD5",
          none: true,
          rsa: false
        ),
        public_key: ""
      ))
      if encryption_type == "MD5"
          password = XET::Hash.digest(password)
      end
      login_command = XET::Command::Login::Request.new(username: username, password: password, encryption_type: encryption_type)
      ::Log.debug { "XET::Socket: Sending login to #{@target.try(&.address)}:#{@target.try(&.port)}" }
      self.send_raw_message login_command.to_s
      ::Log.debug { "XET::Socket: Sent login to #{@target.try(&.address)}:#{@target.try(&.port)}" }

      reply = receive_message[0]
      ::Log.debug { "XET::Socket: Received Reply from #{@target.try(&.address)}:#{@target.try(&.port)}" }

      begin
        net_com_reply = XET::Command::Network::Common::Reply.from_msg(reply)
        ::Log.debug {  "XET::Socket.login: GOT: #{JSON.parse(reply.message)["Ret"]} from #{@target.try(&.address)}:#{@target.try(&.port)}" }
        unless [ XET::Command::Login::Ret::ADMIN_SUCCESS,  XET::Command::Login::Ret::DEFAULT_SUCCESS].includes? net_com_reply.ret
          raise XET::Error::Login::Failure.new
        end
      rescue e
        # Specially filter out json "unexpected char/token" error
        raise e unless e.to_s =~ /^[Uu]nexpected/
      end
    rescue XET::Error::Command::CannotParse
      raise XET::Error::Login::Failure.new
    rescue e : IO::EOFError
      raise XET::Error::Login::EOF.new
    rescue e : IO::TimeoutError
      raise XET::Error::Login::Timeout.new
    rescue e
      if e.to_s.includes? "Connection refused"
        raise XET::Error::Login::ConnectionRefused.new
      elsif e.to_s.includes? "No route to host"
        raise XET::Error::Login::NoRoute.new
      elsif e.to_s.includes? "Broken pipe"
        raise XET::Error::Login::BrokenPipe.new
      elsif e.to_s.includes? "Connection reset"
        raise XET::Error::Login::ConnectionReset.new 
      elsif e.to_s.includes? "Bad file descriptor"
        raise XET::Error::Login::BadFileDescriptor.new 
      else
        raise e
      end
    end
  end

  abstract def receive_message : Tuple(XET::Message, ::Socket::IPAddress)

  def send_message(xmm : XET::Message)
    begin
      self.send_raw_message xmm.to_s
    rescue e : IO::EOFError
      raise XET::Error::Send::EOF.new
    rescue e : IO::TimeoutError
      raise XET::Error::Send::Timeout.new
    rescue e
      if e.to_s.includes? "Connection refused"
        raise XET::Error::Send::ConnectionRefused.new
      elsif e.to_s.includes? "Closed stream"
        raise XET::Error::Socket::Closed.new
      elsif e.to_s.includes? "No route to host"
        raise XET::Error::Send::NoRoute.new
      elsif e.to_s.includes? "Broken pipe"
        raise XET::Error::Send::BrokenPipe.new
      elsif e.to_s.includes? "Connection reset"
        raise XET::Error::Send::ConnectionReset.new 
      elsif e.to_s.includes? "Bad file descriptor"
        raise XET::Error::Send::BadFileDescriptor.new 
      else
        raise e
      end
    end
  end
end

class XET::Socket::TCP < TCPSocket
  
  include XET::Socket

  def initialize
    super Socket::Family::INET, Socket::Type::STREAM, Socket::Protocol::IP
    self.read_timeout = 1
  end

  def initialize(ip_addr : ::Socket::IPAddress)
    begin
      super ip_addr.address, ip_addr.port
      set_target(ip_addr.address, ip_addr.port)
      self.read_timeout = 1
    rescue e
      if e.to_s.includes? "Connection refused"
        raise XET::Error::Socket::ConnectionRefused.new
      elsif e.to_s.includes? "No route to host"
        raise XET::Error::Socket::NoRoute.new
      elsif e.to_s.includes? "Broken pipe"
        raise XET::Error::Socket::BrokenPipe.new
      elsif e.to_s.includes? "Connection reset"
        raise XET::Error::Socket::ConnectionReset.new 
      else
        raise e
      end
    end
  end

  def initialize(host, port)
    begin
      super host, port
      set_target(host, port)
      self.read_timeout = 1
    rescue e
      if e.to_s.includes? "Connection refused"
        raise XET::Error::Socket::ConnectionRefused.new
      elsif e.to_s.includes? "No route to host"
        raise XET::Error::Socket::NoRoute.new
      elsif e.to_s.includes? "Broken pipe"
        raise XET::Error::Socket::BrokenPipe.new
      elsif e.to_s.includes? "Connection reset"
        raise XET::Error::Socket::ConnectionReset.new 
      else
        raise e
      end
    end
  end

  def send_raw_message(message)
    message.to_s self
  end

  def receive_message : Tuple(XET::Message, ::Socket::IPAddress)
    begin
      # TODO: This needs fixing....
      packet_in = self.receive(1000)
      {XET::Message.from_s(packet_in[0]), packet_in[1].as(::Socket::IPAddress)}
    rescue e : IO::TimeoutError
      raise XET::Error::Receive::Timeout.new
    rescue e : IO::Error
      raise XET::Error::Socket::Closed.new if e.to_s.includes? "Closed"
      raise e
    end
  end
end

class XET::Socket::UDP < UDPSocket
  
  include XET::Socket

  def initialize
    begin
      super()
      self.read_timeout = 10
    rescue e
      if e.to_s.includes? "Connection refused"
        raise XET::Error::Socket::ConnectionRefused.new
      elsif e.to_s.includes? "No route to host"
        raise XET::Error::Socket::NoRoute.new
      elsif e.to_s.includes? "Broken pipe"
        raise XET::Error::Socket::BrokenPipe.new
      elsif e.to_s.includes? "Connection reset"
        raise XET::Error::Socket::ConnectionReset.new 
      else
        raise e
      end
    end
  end

  def initialize(host, port)
    begin
      super()
      set_target(host, port)
      self.read_timeout = 10
    rescue e
      if e.to_s.includes? "Connection refused"
        raise XET::Error::Socket::ConnectionRefused.new
      elsif e.to_s.includes? "No route to host"
        raise XET::Error::Socket::NoRoute.new
      elsif e.to_s.includes? "Broken pipe"
        raise XET::Error::Socket::BrokenPipe.new
      elsif e.to_s.includes? "Connection reset"
        raise XET::Error::Socket::ConnectionReset.new 
      else
        raise e
      end
    end
  end

  def send_raw_message(message)
    if target = @target
      self.send(message.to_s, target)
    else
      raise "Socket has no target!"
    end
  end

  def send_raw_message(message, to : ::Socket::IPAddress)
    self.send(message.to_s, to)
  end

  def send_message(xmm : XET::Message, to : ::Socket::IPAddress)
    begin
      self.send_raw_message xmm.to_s, to
    rescue e : IO::EOFError
      raise XET::Error::Send::EOF.new
    rescue e : IO::TimeoutError
      raise XET::Error::Send::Timeout.new
    rescue e
      if e.to_s.includes? "Connection refused"
        raise XET::Error::Send::ConnectionRefused.new
      elsif e.to_s.includes? "Closed stream"
        raise XET::Error::Socket::Closed.new
      elsif e.to_s.includes? "No route to host"
        raise XET::Error::Send::NoRoute.new
      elsif e.to_s.includes? "Broken pipe"
        raise XET::Error::Send::BrokenPipe.new
      elsif e.to_s.includes? "Connection reset"
        raise XET::Error::Send::ConnectionReset.new 
      elsif e.to_s.includes? "Bad file descriptor"
        raise XET::Error::Send::BadFileDescriptor.new 
      else
        raise e
      end
    end
  end

  def receive_message : Tuple(XET::Message, ::Socket::IPAddress)
    begin
      # TODO: This needs fixing....
      packet_in = self.receive(1000)
      {XET::Message.from_s(packet_in[0]), packet_in[1]}
    rescue e : IO::TimeoutError
      raise XET::Error::Receive::Timeout.new
    rescue e : IO::Error
      raise XET::Error::Socket::Closed.new if e.to_s.includes? "Closed"
      raise e
    end
  end
end