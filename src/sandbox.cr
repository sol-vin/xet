require "clim"

module XET
  module CLI
    class Send < Clim
      main do
        desc "Sends a message and attempts to receive on back"
        usage "xet send [args] -q [ip]"
        version "Version #{XET::VERSION}"

        option "-q DEST_IP", "--destination=DEST_IP", type: String, desc: "The IP that you would like to send a message to", required: true
        option "-r PORT", "--port=PORT", type: UInt16, desc: "Specifies the port", default: 34567_u16
        option "-s PORT_TYPE", "--connection=PORT_TYPE", type: String, desc: "Specifies the port type. Either TCP or UDP", default: "tcp"
        option "-t TIMEOUT", "--timeout=TIMEOUT", type: UInt32, desc: "How long to wait for a reply in seconds", default: "tcp"

        option "-u USER", "--user=USER", type: String, desc: "The username for the camera.", default: "admin"
        option "-p PASSWORD", "--password=PASSWORD", type: String, desc: "The password for the camera.", default: ""
        option "-n", "--no-login", type: Bool, desc: "If we should login before sending the command", default: false

        option "-a TYPE", "--type=TYPE", type: String, desc: "The type field of the packet", default: XET::Message::Defaults::TYPE
        option "-b VERSION", "--version=VERSION", type: String, desc: "The version field of the packet", default: XET::Message::Defaults::VERSION
        option "-c TYPE", "--type=TYPE", type: String, desc: "The type field of the packet", default: XET::Message::Defaults::TYPE
        option "-d VERSION", "--version=VERSION", type: String, desc: "The version field of the packet", default: XET::Message::Defaults::VERSION
      end
    end
  end
end

XET::CLI::Send.start(ARGV)
