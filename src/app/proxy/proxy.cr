class XET::App::Proxy
  @socket_tcp : XET::Socket::TCP
  @socket_udp : XET::Socket::UDP
  @socket_discovery : XET::Socket::UDP

  getter tcp_port = XET::DEFAULT_TCP_PORT
  getter udp_port = XET::DEFAULT_UDP_PORT
  getter discovery_port = XET::DEFAULT_DISCOVERY_PORT


  def initialize(@tcp_port = XET::DEFAULT_TCP_PORT, @udp_port = XET::DEFAULT_UDP_PORT, @discovery_port = XET::DEFAULT_DISCOVERY_PORT)
    @socket_tcp = XET::Socket::TCP.new
    @socket_udp = XET::Socket::UDP.new
    @socket_discovery = XET::Socket::UDP.new
  end
end