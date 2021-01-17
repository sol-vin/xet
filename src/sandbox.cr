require "./xet"


msg = XET::Command::Network::Common::Reply.new(
  config: XET::Command::Network::Common::Reply::Config.new(
    build_date: "????",
    channel_num: 1_u32,
    device_type: "IPC",
    gateway: ::Socket::IPAddress.new("192.168.1.1", 0),
    host_ip: ::Socket::IPAddress.new("192.168.1.88", 0),
    hostname: "imahost",
    http_port: 80_u16,
    mac: "11:22:33:44:55::66",
    max_bps: 0_u32,
    mon_mode: "idk",
    net_connect_state: 123,
    other_function: "asdfasdfsdf",
    serial_number: "123456ABCDEF",
    ssl_port: 443_u16,
    submask: ::Socket::IPAddress.new("255.255.255.0", 0),
    tcp_max_connections: 444_u32,
    tcp_port: 999_u16,
    transfer_plan: "srslyidk",
    udp_port: 321_u16,
    use_hs_download: true
  ),
  ret: 1234,
  session_id_message: XET::SessionID.new(0xAABBCCDD_u32)
)
xmsg = XET::Command::Network::Common::Reply.from_msg(msg.as(XET::Message))

pp xmsg.message

