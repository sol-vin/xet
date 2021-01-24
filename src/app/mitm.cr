class XET::App::MITM
  @socket_tcp : XET::Socket::TCP
  @socket_udp : XET::Socket::UDP
  @socket_discovery : XET::Socket::UDP

  getter tcp_port = XET::DEFAULT_TCP_PORT
  getter udp_port = XET::DEFAULT_UDP_PORT
  getter discovery_port = XET::DEFAULT_DISCOVERY_PORT


  def initialize(@tcp_port = XET::DEFAULT_TCP_PORT, @udp_port = XET::DEFAULT_UDP_PORT, @discovery_port = XET::DEFAULT_DISCOVERY_PORT)
  end

  # What needs to happen:
  # Client sends out broadcast Network::Common::Request
  # Cameras send out broadcast Network::Common::Reply
  # Run all replies through a filter(ip, mac, sn, etc)
  # Save all Network::Common::Reply that passes the filter to an array after altering each one with the proper data where needed
  # Send out DoS to each camera
  # Create a MITM server for each camera (see if we can modify the ports for tcp, udp, etc)
  # Spam modified Network::Common::Reply to client for all spoofed cameras
  # Hijack credentials
end