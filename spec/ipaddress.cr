it "should allow Socket::IPAddress to string" do
  ::Socket::IPAddress.new("0.0.0.0", 0).to_json.should eq %q["0x00000000"]
  ::Socket::IPAddress.new("0.0.0.1", 0).to_json.should eq %q["0x01000000"]
  ::Socket::IPAddress.new("1.0.0.0", 0).to_json.should eq %q["0x00000001"]
end