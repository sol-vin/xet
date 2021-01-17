command Network::Common::Request, id: 0x05fa

command Network::Common::Reply, id: 0x05fb do
  nest config, Config, "NetWork.NetCommon" do
    field? build_date, String, "BuildDate"
    field? channel_num, UInt32, "ChannelNum"
    field? device_type, IString, "DeviceType"
    field? gateway, ::Socket::IPAddress, "GateWay"
    field? host_ip, ::Socket::IPAddress, "HostIP"
    field? hostname, String, "HostName"
    field? http_port, UInt16, "HttpPort"
    field? mac, String, "MAC"
    field? max_bps, UInt32, "MaxBps"
    field? mon_mode, String, "MonMode"
    field? net_connect_state, Int32, "NetConnectState"
    field? other_function, String, "OtherFunction"
    field? serial_number, String, "SN"
    field? ssl_port, UInt16, "SSLPort"
    field? submask, ::Socket::IPAddress, "Submask"
    field? tcp_max_connections, UInt32, "TCPMaxConn"
    field? tcp_port, UInt16, "TCPPort"
    field? transfer_plan, String, "TransferPlan"
    field? udp_port, UInt16, "UDPPort"
    field? use_hs_download, Bool, "UseHSDownLoad"
  end
  field? ret, Int32, "Ret"
  field session_id_message, String, "SessionID", default: "0x00000000"
end

