class XET::App::Target
  property name : String
  property discovery_port : UInt16 = 34569_u16
  property config : XET::Command::Network::Common::Reply::Config
  def initialize(@name, @config = XET::Command::Network::Common::Reply::Config.new)
  end
end