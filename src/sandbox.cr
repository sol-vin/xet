require "./xet"


msg = XET::Command::Operation::System::Upgrade::Reply.new(
  config: XET::Command::Operation::System::Upgrade::Reply::Config.new(
    hardware: "yes", 
    logo_area: XET::Command::Operation::System::Upgrade::Reply::Config::LogoArea.new(
      start: "hello", 
      finish: "world"
      )
    ), 
  ret: 1234
)
msg.build_message!
xmsg = XET::Command::Operation::System::Upgrade::Reply.from_msg(msg)

pp xmsg.message

