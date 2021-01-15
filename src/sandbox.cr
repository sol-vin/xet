require "./xet"


msg = XET::Command::Operation::System::Upgrade::Reply.new(config: XET::Command::Operation::System::Upgrade::Reply::Config.new(hardware: "yes", logo_area: XET::Command::Operation::System::Upgrade::Reply::Config::LogoArea.new()), ret: 1234)
msg.build_message!
xmsg = XET::Command::Operation::System::Upgrade::Reply.from_json(msg.message)
{% pp XET::Command::Operation::System::Upgrade::Reply::Config::LogoArea.ancestors %}

pp xmsg