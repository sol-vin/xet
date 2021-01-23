require "option_parser"
require "../xet"

macro p_on(name, a_type, cmd_letter, message)
  parser.on("-{{cmd_letter.id}} {{name.upcase.id}}", "--{{name.id}}={{name.upcase.id}}", "{{message.id}} (default: #{XET::Message::Defaults::{{name.upcase.id}}})") do |msg_value|

  message_procs << ->(msg : XET::Message) do
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
end


template = XET::Message
message_procs = [] of Proc(XET::Message, Nil)

padding = " "*10

begin
  OptionParser.parse! do |parser|
    parser.banner = "Usage: xmessage [arguments]"

    parser.on("-t TEMPLATE", "--template=TEMPLATE", "The Template XET::Message (default: #{template})" \
                                                    "\n#{padding}Available Templates: #{XET::Commands.to_h.values.to_s.gsub(/XET::Command::/, "").gsub(/[ ,\[\]]+/, "\n#{padding}    ")}") do |command_name| 
      new_command_name = command_name =~ /^XET::Command::/ ? command_name : "XET::Command::#{command_name}" 
      if XET::Commands[new_command_name]?
        template = XET::Commands[new_command_name]
      else
        puts "Template #{command_name} does not exist!"
        exit
      end
    end

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

    parser.on("-m MESSAGE", "--message=MESSAGE", "The JSON message to send") { |message| message_procs << ->(msg : XET::Message) { msg.message = message } }
    parser.on("-?", "--help", "Show this help") { puts parser; exit }

    parser.invalid_option do |flag|
      STDERR.puts "ERROR: #{flag} is not a valid option."
      STDERR.puts parser
      exit(1)
    end
  end
rescue e
  puts "THERE WAS AN ERROR #{e.to_s}"
end

msg = template.new
message_procs.each {|pr| pr.call(msg)}

puts msg.to_s.inspect.gsub(/(^\")|(\"$)/, "\'")