struct ::Socket::IPAddress
  def self.from_json(pull : JSON::PullParser)
    ip = pull.read_string
    if ip.size == 10
      ipv4 = [] of UInt8
      ipv4 << ip[8..9].to_u8(16)
      ipv4 << ip[6..7].to_u8(16)
      ipv4 << ip[4..5].to_u8(16)
      ipv4 << ip[2..3].to_u8(16)
      ip = ipv4.join(".")
    else
      raise "Parsing error!"
    end
    ::Socket::IPAddress.new(ip, 0)    
  end

  def self.to_json(value : ::Socket::IPAddress, build : JSON::Builder)
    build.string("0x#{value.address.split(".").reverse.map(&.to_i.to_s(16).rjust(2, '0')).join}")
  end

  def initialize(pull : JSON::PullParser)
    @port = 0
    ip = pull.read_string
    if ip.chars.size == 10
      ipv4 = [] of UInt8
      ipv4 << ip[8..9].to_u8(16)
      ipv4 << ip[6..7].to_u8(16)
      ipv4 << ip[4..5].to_u8(16)
      ipv4 << ip[2..3].to_u8(16)
      ip = ipv4.join(".")
    else
      raise "Parsing error!"
    end

    @address = ip
    @family = Family::INET
    @size = sizeof(LibC::SockaddrIn)

   if @addr4 = ip4?(address)
    else
      raise ::Socket::Error.new("Invalid IP address: #{address}")
    end
  end

  def to_json(build : JSON::Builder)
    ::Socket::IPAddress.to_json(self, build)
  end
end