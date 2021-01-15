require "./xet"
msg = XET::Command::Login::Request.new(username: "ian", type: 200_u8)
pp msg.to_json
msg.build_message!
pp msg
