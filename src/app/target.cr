class XET::App::Target
  property name : String
  property config : XET::Command::Network::Common::Reply::Config
  def initialize(@name, @config = XET::Command::Network::Common::Reply::Config.new)
  end
end