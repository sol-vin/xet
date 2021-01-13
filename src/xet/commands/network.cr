command Network::Common::Request, id: 0x05fa

command Network::Common::Reply, id: 0x05fb do
  nest config, Config, "NetWork.NetCommon" do
    field? channel_num, UInt32, "ChannelNum"
    field? device_type, String, "DeviceType"
    field? gateway, String, "GateWay"
    field? host_ip, String, "HostIP"
    field? hostname, String, "HostName"
    field? http_port, UInt32, "HttpPort"
    field? mac, String, "MAC"
    field? max_bps, UInt32, "MaxBps"
    field? mon_mode, String, "MonMode"
    field? net_connect_state, Int32, "NetConnectState"
    field? other_function, String, "OtherFunction"
    field? serial_number, String, "SN"
    field? ssl_port, UInt32, "SSLPort"
    field? submask, String, "Submask"
    field? tcp_max_connections, UInt32, "TCPMaxConn"
    field? tcp_port, UInt32, "TCPPort"
    field? transfer_plan, String, "TransferPlan"
    field? udp_port, UInt32, "UDPPort"
    field? use_hs_download, Bool, "UseHSDownLoad"
  end
  field? ret, Int32, "Ret"
  field session_id_message, String, "SessionID", default: "0x00000000"
end