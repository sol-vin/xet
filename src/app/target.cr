class XET::App::Target
  property name : String
  property ip_address : String?
  property mac_address : String?
  property serial_number : String?

  property tcp_port : Int32 = 0
  property udp_port : Int32 = 0
  property http_port : Int32 = 0

  def initialize(@name)
  end
end