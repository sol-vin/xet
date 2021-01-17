describe XET::Command::Operation::System::Upgrade::Reply do
  it "should be able to make a XET::Command::Operation::System::Upgrade::Reply json message" do
    xmsg = XET::Command::Operation::System::Upgrade::Reply.new(
    )

    xmsg.message.should eq ""
  end

  it "should be able to parse a XET::Command::Operation::System::Upgrade::Reply from json" do
    xmsg_json = XET::Command::Operation::System::Upgrade::Reply.new(
    ).to_json

    XET::Command::Operation::System::Upgrade::Reply.from_json(xmsg_json).build_message!.should eq ""
  end

  it "should be able to parse a XET::Command::Operation::System::Upgrade::Reply from XET::Message" do
    xmsg = XET::Command::Operation::System::Upgrade::Reply.new(
    ).as(XET::Message)

    XET::Command::Operation::System::Upgrade::Reply.from_msg(xmsg).message.should eq ""
  end
end