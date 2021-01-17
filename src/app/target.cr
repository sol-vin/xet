class XET::App::Target
  property name : String
  property ip_address : String?
  property mac_address : String?
  property serial_number : String?

  property tcp_port : UInt16?
  property udp_port : UInt16?
  property http_port : UInt16?
  property ssl_port : UInt16?


  def initialize(@name)
  end
end