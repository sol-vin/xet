# This macro makes a command using scaffolding in conjunction with `nest` and `field`.
# Allows you to quickly make and store XET::Message subclasses undet XET::Command, making cleaner and DRYer code.
macro command(class_path, id, 
  type = XET::Message::Defaults::TYPE,
  version = XET::Message::Defaults::VERSION,
  reserved1 = XET::Message::Defaults::RESERVED1,
  reserved2 = XET::Message::Defaults::RESERVED2,
  session_id = XET::Message::Defaults::SESSION_ID,
  sequence = XET::Message::Defaults::SEQUENCE,
  total_packets = XET::Message::Defaults::TOTAL_PACKETS,
  current_packet = XET::Message::Defaults::CURRENT_PACKET,
  size = nil,
  message = "",
  build_message = true,
  &block)

  {% raise "command: class_path was not a Path" unless class_path.is_a? Path %}
  {% raise "command: id was not a NumberLiteral is a #{id.class_name}" unless id.is_a?(NumberLiteral) || id.is_a?(Path) %}
  {% raise "command: type was not a NumberLiteral is a #{type.class_name}" unless type.is_a?(NumberLiteral) || type.is_a?(Path) %}
  {% raise "command: version was not a NumberLiteral is a #{version.class_name}" unless version.is_a?(NumberLiteral) || version.is_a?(Path) %}
  {% raise "command: reserved1 was not a NumberLiteral is a #{reserved1.class_name}" unless reserved1.is_a?(NumberLiteral) || reserved1.is_a?(Path) %}
  {% raise "command: reserved2 was not a NumberLiteral is a #{reserved2.class_name}" unless reserved2.is_a?(NumberLiteral) || reserved2.is_a?(Path) %}
  {% raise "command: session_id was not a NumberLiteral is a #{session_id.class_name}" unless session_id.is_a?(NumberLiteral) || session_id.is_a?(Path) %}
  {% raise "command: sequence was not a NumberLiteral is a #{sequence.class_name}" unless sequence.is_a?(NumberLiteral) || sequence.is_a?(Path) %}
  {% raise "command: total_packets was not a NumberLiteral is a #{total_packets.class_name}" unless total_packets.is_a?(NumberLiteral) || total_packets.is_a?(Path) %}
  {% raise "command: current_packet was not a NumberLiteral is a #{current_packet.class_name}" unless current_packet.is_a?(NumberLiteral) || current_packet.is_a?(Path) %}
  {% raise "command: size was not a NumberLiteral is a #{size.class_name}" unless size.is_a?(NilLiteral) || size.is_a?(NumberLiteral) || size.is_a?(Path) %}
  {% raise "command: message was not a StringLiteral is a #{message.class_name}" unless message.is_a?(StringLiteral) || message.is_a?(Path) %}

  {% begin %}
  class ::XET::Command::{{class_path.id}} < XET::Message
    include JSON::Serializable
    {% if id.is_a? Path %}
    ID = {{id.resolve}}
    {% else %}
    ID = {{id}}_u16
    {% end %}


    # We have to define these variables or we are going to get invalid memory access.
    macro finished
      {% if type.is_a? Path %}
      @type = {{type.resolve}}
      {% else %}
      @type = {{type}}_u8
      {% end %}

      {% if version.is_a? Path %}
      @version = {{version.resolve}}
      {% else %}
      @version = {{version}}_u8
      {% end %}

      {% if reserved1.is_a? Path %}
      @reserved1 = {{reserved1.resolve}}
      {% else %}
      @reserved1 = {{reserved1}}_u8
      {% end %}

      {% if reserved2.is_a? Path %}
      @reserved2 = {{reserved2.resolve}}
      {% else %}
      @reserved2 = {{reserved2}}_u8
      {% end %}

      {% if session_id.is_a? Path %}
      @session_id = {{session_id.resolve}}
      {% else %}
      @session_id = {{session_id}}_u32
      {% end %}

      {% if sequence.is_a? Path %}
      @sequence = {{sequence.resolve}}
      {% else %}
      @sequence = {{sequence}}_u32
      {% end %}
      
      {% if total_packets.is_a? Path %}
      @total_packets = {{total_packets.resolve}}
      {% else %}
      @total_packets = {{total_packets}}_u8
      {% end %}

      {% if current_packet.is_a? Path %}
      @current_packet = {{current_packet.resolve}}
      {% else %}
      @current_packet = {{current_packet}}_u8
      {% end %}

      @id = ID

      {% if size.is_a? Path %}
      @size = {{size.resolve}}
      @use_custom_size = true
      {% elsif size.is_a? NumberLiteral %}
      @size = {{size}}
      @use_custom_size = true
      {% else %}
      @size = XET::Message::Defaults::SIZE
      {% end %}

      {% if message.is_a? Path %}
      @message = {{message.resolve}}
      {% elsif message.is_a? StringLiteral %}
      @message = {{message}}
      {% else %}
      @message = ""
      {% end %}


      def initialize(
        # This enables all the XET::Message variables to be changed from initialize
        {% if type.is_a? Path %}
        @type = {{type.resolve}},
        {% else %}
        @type = {{type}}_u8,
        {% end %}
  
        {% if version.is_a? Path %}
        @version = {{version.resolve}},
        {% else %}
        @version = {{version}}_u8,
        {% end %}
  
        {% if reserved1.is_a? Path %}
        @reserved1 = {{reserved1.resolve}},
        {% else %}
        @reserved1 = {{reserved1}}_u8,
        {% end %}
  
        {% if reserved2.is_a? Path %}
        @reserved2 = {{reserved2.resolve}},
        {% else %}
        @reserved2 = {{reserved2}}_u8,
        {% end %}
  
        {% if session_id.is_a? Path %}
        @session_id = {{session_id.resolve}},
        {% else %}
        @session_id = {{session_id}}_u32,
        {% end %}
  
        {% if sequence.is_a? Path %}
        @sequence = {{sequence.resolve}},
        {% else %}
        @sequence = {{sequence}}_u32,
        {% end %}
        
        {% if total_packets.is_a? Path %}
        @total_packets = {{total_packets.resolve}},
        {% else %}
        @total_packets = {{total_packets}}_u8,
        {% end %}
  
        {% if current_packet.is_a? Path %}
        @current_packet = {{current_packet.resolve}},
        {% else %}
        @current_packet = {{current_packet}}_u8,
        {% end %}
  
        @id = ID,
  
        {% if size.is_a? Path %}
        @size = {{size.resolve}},
        {% elsif size.is_a? NumberLiteral %}
        @size = {{size}},
        {% else %}
        @size = XET::Message::Defaults::SIZE,
        {% end %}
  
        {% if message.is_a? Path %}
        @message = {{message.resolve}},
        {% elsif message.is_a? StringLiteral %}
        @message = {{message}},
        {% else %}
        @message = "",
        {% end %}
        # This adds all the fields to the initialize args.
        {% verbatim do %}
          {% for m in @type.methods.select {|m| m.annotation(XET::Field) } %}
            @{{m.name.id}}  : {{m.annotation(XET::Field).named_args[:type]}} = {{m.annotation(XET::Field).named_args[:default]}},
          {% end %}
        {% end %}
      )
      {% if size.is_a? Path || size.is_a? NumberLiteral %}
      @use_custom_size = true
      {% end %}

      {% if (block && build_message) %}
      build_message!
      {% end %}

      end
    end

  
    def build_message!
      @message = self.to_json
    end

    def self.from_msg(msg : XET::Message) : ::XET::Command::{{class_path.id}}
      begin
        parsed_command = ::XET::Command::{{class_path.id}}.from_json(msg.message)

        parsed_command.type = msg.type
        parsed_command.version = msg.version
        parsed_command.reserved1 = msg.reserved1
        parsed_command.reserved2 = msg.reserved2
        parsed_command.session_id = msg.session_id
        parsed_command.sequence = msg.sequence
        parsed_command.total_packets = msg.total_packets
        parsed_command.current_packet = msg.current_packet
        parsed_command.id = msg.id
        parsed_command.size = msg.size
        parsed_command.message = msg.message
        parsed_command.use_custom_size = msg.use_custom_size?
        {% if (block && build_message) %}
        parsed_command.build_message!
        {% end  %}
        parsed_command
      rescue exception : JSON::ParseException
        raise XET::Error::Command::CannotParse.new
      end
    end

    def self.from_msg?(msg : XET::Message) : self
      begin
        from_msg(msg)
      rescue exception : XET::Error::Command::CannotParse
        nil 
      end
    end

    {{ yield }}
  end
  {% end %}
end