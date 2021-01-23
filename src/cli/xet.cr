require "clim"

require "../app_lib"

macro xsock_opts_parse(name, type)
  if %name = opts.{{name.id}}
    value = 0
    begin
      if %name =~ /^0x[0-9a-fA-f]{1,8}$/
        value = %name[2..].to_i(16)
      elsif  %name =~ /^0b[01]{8,32}$/
        value = %name[2..].to_i(2)
      else
        value = %name.to_i
      end
      {% r_type = type.resolve %}
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
        raise "{{type}} not supported"
      {% end %}

    rescue e
      puts "ERROR: {{name}} was not a {{type}}(min:#{{{type}}::MIN},max:#{{{type}}::MAX}), instead was #{opts.{{name.id}}}|#{value}"
      exit
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


module XET
  class CLI < Clim
    main do
      desc "XET - Xiongmai Exploitation Toolkit"
      usage "xet [sub_command] [arguments] ..."
      version "Version #{XET::VERSION}"
      run do |opts, args|
        puts opts.help_string # => help string.
      end

      sub "web" do
        desc "Runs the web interface"
        option "-p PORT", "--port=PORT", type: UInt16, desc: "Specifies the port", default: 4000
        option "-i INTERFACE", "--interface=INTERFACE", type: String, desc: "Specifies the port", default: "enp3s0"

        usage "xet web [options]"
        run do |opts, args|
          XET::App.run(port: opts.port, interface: opts.interface)
        end
      end

      sub "send" do
        desc "Sends a message and attempts to receive on back"
        usage "xet send [options] [destination]"

        argument "destination", type: String, desc: "IP to send the message to", required: true

        option "-r PORT", "--port=PORT", type: UInt16, desc: "Specifies the port", default: 34567
        option "-s PORT_TYPE", "--connection=PORT_TYPE", type: String, desc: "Specifies the port type. Either TCP or UDP", default: "tcp"
        option "-t TIMEOUT", "--timeout=TIMEOUT", type: UInt32, desc: "How long to wait for a reply in seconds", default: 5
        option "-l", "--no-listen", type: Bool, default: false

        

        option "-u USER", "--user=USER", type: String, desc: "The username for the camera.", default: "admin"
        option "-p PASSWORD", "--password=PASSWORD", type: String, desc: "The password for the camera.", default: ""
        option "-n", "--no-login", type: Bool, desc: "If we should login before sending the command", default: false

        option "-v", "--verbose", type: Bool, desc: "Print more debugging information to STDERR", default: false
        option "-w TEMPLATE", "--template=TEMPLATE", type: String, desc: "Template for the message. Use '-w ?'' to see available templates", default: "Blank"

        option "-a TYPE", "--type=TYPE", type: String, desc: "The type field of the packet"
        option "-b VERSION", "--version=VERSION", type: String, desc: "The version field of the packet"
        option "-c RESERVED1", "--reserved1=RESERVED1", type: String, desc: "The reserved1 field of the packet"
        option "-d RESERVED2", "--reserved2=RESERVED2", type: String, desc: "The reserved2 field of the packet"
        option "-e SESSION_ID", "--session_id=SESSION_ID", type: String, desc: "The session_id field of the packet"
        option "-f SEQUENCE", "--sequence=SEQUENCE", type: String, desc: "The sequence field of the packet"
        option "-g TOTAL_PACKETS", "--total_packets=TOTAL_PACKETS", type: String, desc: "The total_packets field of the packet"
        option "-h CURRENT_PACKET", "--current_packet=CURRENT_PACKET", type: String, desc: "The current_packet field of the packet"
        option "-i ID", "--id=ID", type: String, desc: "The id field of the packet"
        option "-j SIZE", "--size=SIZE", type: String, desc: "The size field of the packet"
        option "-m MESSAGE", "--message=MESSAGE", type: String, desc: "The JSON message to send"

        run do |opts, args|
          unless ["tcp", "udp"].any? { |t| opts.connection == t }
            puts "Invalid port_type -s #{opts.connection} must be tcp or udp"
            exit
          end

          template_class = XET::Command::Blank
          full_command_name = opts.template =~ /^XET::Command::/ ? opts.template : "XET::Command::#{opts.template}"

          if XET::Commands[full_command_name]?
            template_class = XET::Commands[full_command_name]
          else
            puts "NOT A VALID TEMPLATE #{opts.template}|#{full_command_name}" unless opts.template == "?"
            puts "Available Templates: \n#{XET::Commands.to_h.values.join("\n").gsub(/XET::Command::/, "")}"
            exit
          end

          msg = template_class.new

          xsock_opts_parse(type, UInt8)
          xsock_opts_parse(version, UInt8)
          xsock_opts_parse(reserved1, UInt8)
          xsock_opts_parse(reserved2, UInt8)
          xsock_opts_parse(session_id, UInt32)
          xsock_opts_parse(sequence, UInt32)
          xsock_opts_parse(total_packets, UInt8)
          xsock_opts_parse(current_packet, UInt8)
          xsock_opts_parse(id, UInt16)
          xsock_opts_parse(size, UInt32)
          msg.message = opts.message.to_s



          # Fix size
          unless msg.use_custom_size?
            msg.size = msg.message.size.to_u32
          end

          begin
            # Open up a socket
            if opts.connection == "tcp"
              socket = XET::Socket::TCP.new(args.destination, opts.port)
              socket.broadcast = true
              socket.read_timeout = opts.timeout.seconds
              if !opts.no_login
                socket.login(opts.user, opts.password)
              end
              socket.send_message msg
              puts "Sent Packet!"
              puts
              print_msg(msg)
              unless opts.no_listen
                rmsg = socket.receive_message
                puts
                puts "Got Reply!"
                puts
                print_msg(rmsg)
              end
              socket.close
            elsif opts.connection == "udp"
              socket = XET::Socket::UDP.new(args.destination, opts.port)
              socket.broadcast = true
              socket.read_timeout = opts.timeout.seconds
              if !opts.no_login
                socket.login(opts.user, opts.password)
              end
              socket.send_message msg
              puts "Sent Packet!"
              puts
              print_msg(msg)
              unless opts.no_listen
                rmsg = socket.receive_message
                puts
                puts "Got Reply!"
                puts
                print_msg(rmsg)
              end
              socket.close
            else
              puts "ERROR: Dont know how you got here"
              exit
            end
          rescue e
            puts "Error: #{e.inspect}"
          end
        end
      end

      sub "msg" do
        desc "Creates a message and outputs it in various formats"
        usage "xet msg [options]"
        option "-w TEMPLATE", "--template=TEMPLATE", type: String, desc: "Template for the message. Use '-w ?'' to see available templates", default: "Blank"

        option "-a TYPE", "--type=TYPE", type: String, desc: "The type field of the packet"
        option "-b VERSION", "--version=VERSION", type: String, desc: "The version field of the packet"
        option "-c RESERVED1", "--reserved1=RESERVED1", type: String, desc: "The reserved1 field of the packet"
        option "-d RESERVED2", "--reserved2=RESERVED2", type: String, desc: "The reserved2 field of the packet"
        option "-e SESSION_ID", "--session_id=SESSION_ID", type: String, desc: "The session_id field of the packet"
        option "-f SEQUENCE", "--sequence=SEQUENCE", type: String, desc: "The sequence field of the packet"
        option "-g TOTAL_PACKETS", "--total_packets=TOTAL_PACKETS", type: String, desc: "The total_packets field of the packet"
        option "-h CURRENT_PACKET", "--current_packet=CURRENT_PACKET", type: String, desc: "The current_packet field of the packet"
        option "-i ID", "--id=ID", type: String, desc: "The id field of the packet"
        option "-j SIZE", "--size=SIZE", type: String, desc: "The size field of the packet"
        option "-m MESSAGE", "--message=MESSAGE", type: String, desc: "The JSON message to send"

        run do |opts, args|
          template_class = XET::Command::Blank
          full_command_name = opts.template =~ /^XET::Command::/ ? opts.template : "XET::Command::#{opts.template}"

          if XET::Commands[full_command_name]?
            template_class = XET::Commands[full_command_name]
          else
            puts "NOT A VALID TEMPLATE #{opts.template}|#{full_command_name}" unless opts.template == "?"
            puts "Available Templates: \n#{XET::Commands.to_h.values.join("\n").gsub(/XET::Command::/, "")}"
            exit
          end

          msg = template_class.new

          xsock_opts_parse(type, UInt8)
          xsock_opts_parse(version, UInt8)
          xsock_opts_parse(reserved1, UInt8)
          xsock_opts_parse(reserved2, UInt8)
          xsock_opts_parse(session_id, UInt32)
          xsock_opts_parse(sequence, UInt32)
          xsock_opts_parse(total_packets, UInt8)
          xsock_opts_parse(current_packet, UInt8)
          xsock_opts_parse(id, UInt16)
          xsock_opts_parse(size, UInt32)
          msg.message = opts.message.to_s



          # Fix size
          unless msg.use_custom_size?
            msg.size = msg.message.size.to_u32
          end

          puts msg.to_s.inspect.gsub(/(^\")|(\"$)/, "\'")
        end
      end
    end
  end
end

XET::CLI.start(ARGV)
