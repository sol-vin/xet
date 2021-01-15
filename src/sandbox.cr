require "./xet"


msg = XET::Command::Login::Request.new(username: "ian", password: "dunkin")
msg.build_message!
pp msg.message

msg = XET::Command::Network::Common::Reply.new(config: XET::Command::Network::Common::Reply::Config.new(channel_num: 1), ret: 1234)
msg.build_message!
pp XET::Command::Network::Common::Reply.from_json(msg.message)
