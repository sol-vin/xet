require "option_parser"
require "../app_lib"

SOCKET_TYPES = ["tcp", "udp"]

port = nil
port_type = nil
dest_ip = nil

msg = XET::Message.new

begin
  OptionParser.parse! do |parser|
    parser.banner = "Usage: xet_socket [arguments]"
    # parser.on("-u", "--upcase", "Upcases the salute") {  }
    # parser.on("-t NAME", "--to=NAME", "Specifies the name to salute") { |name| }
    parser.on("-p PORT", "--port=PORT", "Specifies the port") { |_port| port = _port }
    parser.on("-x PORT_TYPE", "--connection=PORT_TYPE", "Specifies the type of port (tcp, udp)") { |_port_type| port_type = _port_type }
    parser.on("-q DEST_IP", "--destination=DEST_IP", "The IP to send the message") { |_dest_ip| dest_ip = _dest_ip }

    parser.on("-a TYPE", "--type=TYPE", "The type field of the message (default: #{XET::Message::Defaults::TYPE})") { |_msg_type| msg.type = _msg_type.to_u8 }
    parser.on("-b VERSION", "--version=VERSION", "The version field of the message (default: #{XET::Message::Defaults::VERSION})") { |_msg_version| msg.version = _msg_version.to_u8 }
    parser.on("-c RESERVED1", "--reserved1=RESERVED1", "The reserved1 field of the message (default: #{XET::Message::Defaults::RESERVED1})") { |_msg_reserved1| msg.reserved1 = _msg_reserved1.to_u8 }
    parser.on("-d RESERVED2", "--reserved2=RESERVED2", "The reserved2 field of the message (default: #{XET::Message::Defaults::RESERVED2})") { |_msg_reserved2| msg.reserved2 = _msg_reserved2.to_u8 }
    parser.on("-e SESSION_ID", "--session_id=SESSION_ID", "The session id field of the message (default: #{XET::Message::Defaults::SESSION_ID})") { |_msg_session_id| msg.session_id = _msg_session_id.to_u32 }
    parser.on("-f SEQUENCE", "--sequence=SEQUENCE", "The sequence field of the message (default: #{XET::Message::Defaults::SEQUENCE})") { |_msg_sequence| msg.sequence = _msg_sequence.to_u32 }
    parser.on("-g TOTAL_PACKETS", "--total_packets=TOTAL_PACKETS", "The total packets field of the message (default: #{XET::Message::Defaults::TOTAL_PACKETS})") { |_msg_total_packets| msg.total_packets = _msg_total_packets.to_u8 }
    parser.on("-h CURRENT_PACKET", "--current_packet=CURRENT_PACKET", "The current packet field of the message (default: #{XET::Message::Defaults::CURRENT_PACKET})") { |_msg_current_packet| msg.current_packet = _msg_current_packet.to_u8 }
    parser.on("-i ID", "--id=ID", "The command id field of the message (default: #{XET::Message::Defaults::ID})") { |_msg_id| msg.id = _msg_id.to_u16 }
    parser.on("-j SIZE", "--size=SIZE", "The size field of the message (leave out to calculate size from the message instead!)") { |_msg_size| msg.size = _msg_size.to_u32 }

    parser.on("-?", "--help", "Show this help") { puts parser }

    parser.invalid_option do |flag|
      STDERR.puts "ERROR: #{flag} is not a valid option."
      STDERR.puts parser
      exit(1)
    end
  end
rescue e
  STDERR.puts "ERROR: #{e.to_s}"
end