module XET::Command::Login
  SUCCESS = 100
  UNKNOWN = 106
  FAILURE = 205
  UNKOWN_FAILURE = 206

  DEFAULT_ADMIN_USER = "admin"
  DEFAULT_ADMIN_PASSWORD = ""

  DEFAULT_USER = "default"
  DEFAULT_PASSWORD = "tluafed"

  TYPES = [
    "GUI",
    "Console",
    "DVRIP-Web",
    "DVRIP-SNS",
    "DVRIP-Mobile",
    "DVRIP-Server",
    "DVRIP-Upgrade",
    "DVRIP-AutoSearch",
    "DVRIP-NetKeyboard",
    "DVRIP-Xm030"
  ]

  CRYPTO = ["None", "MD5", "3DES"]
  DEVICE_TYPES = ["DVR", "DVS", "IPC"]
end

command Login::Request, id: 0x03e8 do
  field? username, String, "UserName"
  field? password, String, "PassWord"
  field? login_type, String, "LoginType"
  field? encryption_type, String, "EncryptType"
end

command Login::Reply, id: 0x03e8 do
  field? alive_interval, UInt32, "AliveInterval"
  field? channel_num, UInt32, "ChannelNum"
  field? device_type, String, "DeviceType"
  field? ret, Int32, "Ret"
end