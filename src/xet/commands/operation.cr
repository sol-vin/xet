module XET::Command::Operation::Monitor
  COMBIN_MODES = ["CONNECT_ALL", "NONE"]
  ACTIONS      = ["Claim"]
  ACTION1S     = ["Start", "Stop", "Claim"]
  STREAM_TYPES = ["Main", "Extra1"]
  TRANS_MODES  = ["TCP"]
end

command Operation::Monitor::Request, id: 0x0585 do
  field name, String, "Name", "OPMonitor"
  nest config, Config, "OPMonitor" do
    field? channel, UInt32, "Channel"
    field? combine_mode, Int32, "CombinMode"
    field? stream_type, Int32, "StreamType"
    field? transport_mode, Int32, "TransMode"
  end
  field session_id_message, String, "SessionID", default: "0x00000000"
end 

command Operation::Monitor::Reply, id: 0x0586 do
  field name, String, "Name", "OPMonitor"
  field? ret, Int32, "Ret"
  field session_id_message, String, "SessionID", default: "0x00000000"
end 

module XET::Command::Operation::System::Upgrade
  HARDWARE = "HI3516EV100_50H20L_S38"
end

command Operation::System::Upgrade::Request, id: 0x05f5 do
  field name, String, "Name", "OPSystemUpgrade"
  field session_id_message, String, "SessionID", default: "0x00000000"
end

command Operation::System::Upgrade::Reply, id: 0x05f5 do
  field name, String, "Name", "OPSystemUpgrade"
  nest config, Config, "OPSystemUpgrade" do
    field? hardware, String, "Hardware"
    nest logo_area, LogoArea, "LogoArea" do
      field? start, String, "Begin"
      field? finish, String, "End"
    end
    field? logo_part_type, String, "LogoPartType"
    field? serial, String, "Serial"
    field? vendor, String, "Vendor"
  end
  field? ret, Int32, "Ret"
  field session_id_message, String, "SessionID", default: "0x00000000"
end


