class XET::App::ProxyHandler
  # What needs to happen:
  # Client sends out broadcast Network::Common::Request
  # Cameras send out broadcast Network::Common::Reply
  # Run all replies through a filter(ip, mac, sn, etc)
  # Save all Network::Common::Reply that passes the filter to an array after altering each one with the proper data where needed
  # Send out DoS to each camera
  # Create a MITM server for each camera (see if we can modify the ports for tcp, udp, etc)
  # Spam modified Network::Common::Reply to client for all spoofed cameras
  # Hijack credentials

  @default_broadcaster : XET::App::Broadcaster = XET::App::Broadcaster.new(XET::DEFAULT_DISCOVERY_PORT)

  def initialize
  end 
end