module XET::Socket
  getter target = ::Socket::IPAddress.new("0.0.0.0", 0)

  def set_target(socket_ip)
    @target = socket_ip
  end

  # Target a camera.
  def set_target(ip : String, port = 0)
    @target = ::Socket::IPAddress.new(ip, port)
  end
  
  # Have we found at least one target yet?
  def has_target?
    @target.port != 0
  end

  def login(username = "admin", password = "password", encryption_type = "MD5")
    begin
      #self.send_message(XET::Command::Bits::Request.new)
      if encryption_type == "MD5"
          password = XET::Hash.digest(password)
      end
      login_command = XET::Command::Login::Request.new(username: username, password: password, encryption_type: encryption_type)
      self.send_raw_message login_command.to_s
      reply = receive_message
      begin
        unless [ XET::Command::Login::ADMIN_SUCCESS,  XET::Command::Login::DEFAULT_SUCCESS].includes? JSON.parse(reply.message)["Ret"]
          raise XET::Error::Login::Failure.new
        end
      rescue e
        # Specially filter out json "unexpected char/token" error
        raise e unless e.to_s =~ /^[Uu]nexpected/
      end
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

  def receive_message : XET::Message
    begin
      if closed?
        raise XET::Error::Socket::Closed
      else
        m = XET::Message.new
        m.sender_ip = @target.address
        m.sender_port = @target.port
        m.received = true
        m.type = self.read_bytes(UInt8, IO::ByteFormat::LittleEndian)
        m.version = self.read_bytes(UInt8, IO::ByteFormat::LittleEndian)
        m.reserved1 = self.read_bytes(UInt8, IO::ByteFormat::LittleEndian)
        m.reserved2 = self.read_bytes(UInt8, IO::ByteFormat::LittleEndian)
        m.session_id = self.read_bytes(UInt32, IO::ByteFormat::LittleEndian)
        m.sequence = self.read_bytes(UInt32, IO::ByteFormat::LittleEndian)
        m.total_packets = self.read_bytes(UInt8, IO::ByteFormat::LittleEndian)
        m.current_packet = self.read_bytes(UInt8, IO::ByteFormat::LittleEndian)
        m.id = self.read_bytes(UInt16, IO::ByteFormat::LittleEndian)
        m.size = self.read_bytes(UInt32, IO::ByteFormat::LittleEndian)

        unless m.size == 0
          m.message = self.read_string(m.size-1)
        end

        self.read_byte #bleed this byte

        m
      end
    rescue e : IO::EOFError
      raise XET::Error::Receive::EOF.new
    rescue e : IO::TimeoutError
      raise XET::Error::Receive::Timeout.new
    rescue e
      if e.to_s.includes? "Connection refused"
        raise XET::Error::Receive::ConnectionRefused.new
      elsif e.to_s.includes? "No route to host"
        raise XET::Error::Receive::NoRoute.new
      elsif e.to_s.includes? "Broken pipe"
        raise XET::Error::Receive::BrokenPipe.new
      elsif e.to_s.includes? "Connection reset"
        raise XET::Error::Receive::ConnectionReset.new 
      elsif e.to_s.includes? "Bad file descriptor"
        raise XET::Error::Receive::BadFileDescriptor.new 
      else
        raise e
      end
    end
  end

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
    super Socket::Family::INET, Socket::Type::STREAM,  Socket::Protocol::IP
    self.read_timeout = 1
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

  def bind_target(host, port)
    set_target(host, port)
    self.bind host, port
  end

  def send_raw_message(message)
    message.to_s self
  end
end

class XET::Socket::UDP < UDPSocket
  
  include XET::Socket

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
    self.send(message.to_s, target)
  end

  def receive_message : XET::Message
    begin
      packet_in = self.receive(1000)
      XET::Message.from_s(packet_in[0], sender_ip: packet_in[1].address, sender_port: packet_in[1].port, received: true)
    rescue e : IO::TimeoutError
      raise XET::Error::Receive::Timeout.new
    end
  end
end