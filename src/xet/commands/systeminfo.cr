command System::Info::Request, id: 0x03fc do
  field name, String, "Name", "SystemInfo"
  field session_id_message, String, "SessionID", default: "0x00000000"
end 

command System::Info::Reply, id: 0x03fd do
  field name, String, "Name", "SystemInfo"
  nest config, Config, "SystemInfo" do
    field? alarm_in_channel, UInt32, "AlarmInChannel"
    field? alarm_out_channel, UInt32, "AlarmOutChannel"
    field? build_time, String, "BuildTime"
    field? encryption_version, String, "EncryptVersion"
    field? hardware_version, String, "HardWareVersion"
    field? serial_number, String, "SerialNo"
    field? software_version, String, "SoftWareVersion"
    field? talk_in_channel, UInt32, "TalkInChannel"
    field? talk_out_channel, UInt32, "TalkOutChannel"
    field? video_in_channel, UInt32, "VideoInChannel"
    field? video_out_channel, UInt32, "VideoOutChannel"
    field? extra_channel, UInt32, "ExtraChannel"
    field? audio_in_channel, UInt32, "AudioInChannel"
    field? device_run_time, String, "DeviceRunTime"
  end
  field? ret, Int32, "Ret"
  field session_id_message, String, "SessionID", default: "0x00000000"
end 