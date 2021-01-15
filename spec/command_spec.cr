describe XET::Command do
  it "should be able to make a XET::Command::Operation::System::Upgrade::Reply json message" do
    xmsg = XET::Command::Operation::System::Upgrade::Reply.new(
      config: XET::Command::Operation::System::Upgrade::Reply::Config.new(
        hardware: "yes", 
        logo_area: XET::Command::Operation::System::Upgrade::Reply::Config::LogoArea.new(
          start: "hello", 
          finish: "world"
        )
      ),
      ret: 1234
    )

    xmsg.message.should eq "{\"Name\":\"OPSystemUpgrade\",\"OPSystemUpgrade\":{\"Hardware\":\"yes\",\"LogoArea\":{\"Begin\":\"hello\",\"End\":\"world\"}},\"Ret\":1234,\"SessionID\":\"0x00000000\"}"
  end

  it "should be able to parse a XET::Command::Operation::System::Upgrade::Reply from json" do
    xmsg_json = XET::Command::Operation::System::Upgrade::Reply.new(
      config: XET::Command::Operation::System::Upgrade::Reply::Config.new(
        hardware: "yes", 
        logo_area: XET::Command::Operation::System::Upgrade::Reply::Config::LogoArea.new(
          start: "hello",
          finish: "world"
        )
      ), 
      ret: 1234
    ).to_json

    XET::Command::Operation::System::Upgrade::Reply.from_json(xmsg_json).build_message!.should eq "{\"Name\":\"OPSystemUpgrade\",\"OPSystemUpgrade\":{\"Hardware\":\"yes\",\"LogoArea\":{\"Begin\":\"hello\",\"End\":\"world\"}},\"Ret\":1234,\"SessionID\":\"0x00000000\"}"
  end

  it "should be able to parse a XET::Command::Operation::System::Upgrade::Reply from XET::Message" do
    xmsg = XET::Command::Operation::System::Upgrade::Reply.new(
      config: XET::Command::Operation::System::Upgrade::Reply::Config.new(
        hardware: "yes", 
        logo_area: XET::Command::Operation::System::Upgrade::Reply::Config::LogoArea.new(
          start: "hello",
          finish: "world"
        )
      ), 
      ret: 1234
    ).as(XET::Message)

    XET::Command::Operation::System::Upgrade::Reply.from_msg(xmsg).message.should eq "{\"Name\":\"OPSystemUpgrade\",\"OPSystemUpgrade\":{\"Hardware\":\"yes\",\"LogoArea\":{\"Begin\":\"hello\",\"End\":\"world\"}},\"Ret\":1234,\"SessionID\":\"0x00000000\"}"
  end
end