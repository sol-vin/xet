require "option_parser"
require "../app_lib"

macro p_on(name, a_type, cmd_letter, message)
  parser.on("-{{cmd_letter.id}} {{name.upcase.id}}", "--{{name.id}}={{name.upcase.id}}", "{{message.id}} (default: #{XET::Message::Defaults::{{name.upcase.id}}})") do |msg_value|

  value = 0
  begin
    if msg_value =~ /^0x[0-9a-fA-f]{1,8}$/
      value = msg_value[2..].to_i(16)
    elsif  msg_value =~ /^0b[01]{8,32}$/
      value = msg_value[2..].to_i(2)
    else
      value = msg_value.to_i
    end

    {% r_type = a_type.resolve %}
    {% if r_type == ::UInt8 %}
    msg.{{name.id}} = value.to_u8 
    {% elsif r_type == ::UInt16 %}
    msg.{{name.id}} = value.to_u16
    {% elsif r_type == ::UInt32 %}
    msg.{{name.id}} = value.to_u32
    {% elsif r_type == ::String %}
    msg.{{name.id}} = value.to_u32
      {% if name == :size %}
    msg.use_custom_size = true
      {% end %}
    {% else %}
      raise "{{a_type}} not supported"
    {% end %}
  rescue e
   puts "ERROR: {{name}} was not a {{a_type}}(min:#{{{a_type}}::MIN},max:#{{{a_type}}::MAX}), instead was #{msg_value}|#{value}"
  end
 end
end

def print_msg(msg : XET::Message)
  puts "type: #{msg.type} | 0x#{msg.type.to_s(16).rjust(2, '0')}"
  puts "version: #{msg.version} | 0x#{msg.version.to_s(16).rjust(2, '0')}"
  puts "reserved1: #{msg.reserved1} | 0x#{msg.reserved1.to_s(16).rjust(2, '0')}"
  puts "reserved2: #{msg.reserved2} | 0x#{msg.reserved2.to_s(16).rjust(2, '0')}"
  puts "session_id: #{msg.session_id} | 0x#{msg.session_id.to_s(16).rjust(8, '0')}"
  puts "sequence: #{msg.sequence} | 0x#{msg.sequence.to_s(16).rjust(8, '0')}"
  puts "total_packets: #{msg.total_packets} | 0x#{msg.total_packets.to_s(16).rjust(2, '0')}"
  puts "current_packet: #{msg.current_packet} | 0x#{msg.current_packet.to_s(16).rjust(2, '0')}"
  puts "id: #{msg.id} | 0x#{msg.id.to_s(16).rjust(4, '0')}"
  puts "size: #{msg.size} | 0x#{msg.size.to_s(16).rjust(8, '0')}"
  puts "#{`echo '#{msg.message}' | jq .`}"
end

SOCKET_TYPES = ["tcp", "udp"]

port = 34567_u16
port_type = "tcp"
dest_ip = nil
timeout = 5.seconds
username = XET::Command::Login::DEFAULT_ADMIN_USER
password = XET::Command::Login::DEFAULT_ADMIN_PASSWORD

login = true

msg = XET::Message.new

if ARGV.size == 0
  puts "No args! Run this with -? to get help"
  exit
end

begin
  OptionParser.parse! do |parser|
    parser.banner = "Usage: xsocket [arguments]"

    parser.on("-q DEST_IP", "--destination=DEST_IP", "The IP to send the message") { |_dest_ip| dest_ip = _dest_ip }
    parser.on("-r PORT", "--port=PORT", "Specifies the port (default: #{port})") do |_port|
      begin
        port = _port.to_u16
      rescue e
        puts "ERROR: PORT was not a UInt16(min:#{UInt16::MIN},max:#{UInt16::MAX})"
      end
    end

    parser.on("-s PORT_TYPE", "--connection=PORT_TYPE", "Specifies the type of port (tcp, udp) (default: #{port_type})") { |_port_type| port_type = _port_type }
    parser.on("-t TIMEOUT", "--timeout=TIMEOUT", "How long to wait for a reply in seconds (default: #{timeout.seconds})") do |_timeout|
      begin
        timeout = _timeout.to_u32.seconds
      rescue e
        puts "ERROR: PORT was not a UInt32(min:#{UInt32::MIN},max:#{UInt32::MAX})"
      end
    end

    parser.on("-u USER", "--user=USER", "The username for the camera. (default: #{username})") { |_username| username = _username }
    parser.on("-p PASSWORD", "--password=PASSWORD", "The password for the camera. (default: #{password})") { |_username| username = _username }
    parser.on("-n", "--no-login", "Do not login to the camera and just send the message.") { login = false }

    p_on(:type, UInt8, a, "The type field of the message")
    p_on(:version, UInt8, b, "The version field of the message")
    p_on(:reserved1, UInt8, c, "The reserved1 field of the message")
    p_on(:reserved2, UInt8, d, "The reserved2 field of the message")
    p_on(:session_id, UInt32, e, "The session_id field of the message")
    p_on(:sequence, UInt32, f, "The sequence field of the message")
    p_on(:total_packets, UInt8, g, "The total_packets field of the message")
    p_on(:current_packet, UInt8, h, "The total_packets field of the message")
    p_on(:id, UInt16, i, "The command id field of the message")
    p_on(:size, UInt32, j, "The size field of the message")

    parser.on("-m MESSAGE", "--message=MESSAGE", "The JSON message to send") { |message| msg.message = message }
    parser.on("-?", "--help", "Show this help") { puts parser; exit }

    parser.invalid_option do |flag|
      STDERR.puts "ERROR: #{flag} is not a valid option."
      STDERR.puts parser
      exit(1)
    end
  end
rescue e
  STDERR.puts "ERROR: #{e.to_s}"
end

if dest_ip.nil?
  puts "You must specify an IP address with -q"
  exit
end

unless SOCKET_TYPES.any? { |t| port_type == t }
  puts "Invalid port_type -s #{port_type} must be tcp or udp"
  exit
end

# Fix size
unless msg.use_custom_size?
  msg.size = msg.message.size.to_u32
end

begin
  # Open up a socket
  if port_type == "tcp"
    socket = XET::Socket::TCP.new(dest_ip.to_s, port)
    socket.read_timeout = timeout.seconds
    if login
      socket.login(username, password)
    end
    socket.send_message msg
    puts "Sent Packet!"
    puts
    print_msg(msg)
    rmsg = socket.receive_message
    puts
    puts "Got Reply!"
    puts
    print_msg(rmsg)
    socket.close
  elsif port_type == "udp"
    socket = XET::Socket::UDP.new(dest_ip.to_s, port)
    socket.read_timeout = timeout.seconds
    if login
      socket.login(username, password)
    end
    socket.send_message msg
    puts "Sent Packet!"
    puts
    print_msg(msg)
    rmsg = socket.receive_message
    
    puts
    puts "Got Reply!"
    puts
    print_msg(rmsg)
    socket.close
  else
    puts "ERROR: Dont know how you got here"
    exit
  end
rescue e
  puts "Error: #{e.to_s}"
end
