macro command(class_path, id, &block)
  {% raise "command: class_path was not a Path" unless class_path.is_a? Path %}
  {% raise "command: id was not a NumberLiteral" unless id.is_a? NumberLiteral %}

  class ::XET::Command::{{class_path.id}} < XET::Message
    include JSON::Serializable
    ID = {{id}}_u16

    macro finished
      @type = 0xff_u8
      @version = 0x01_u8
      @reserved1 = 0x00_u8
      @reserved2 = 0x00_u8
      @session_id = 0_u32
      @sequence = 0_u32
      @total_packets = 0_u8
      @current_packet = 0_u8
      @id = ID
      @size = 0_u32
      @message = ""
      {% verbatim do %}
        {% for m in @type.methods.select {|m| m.annotation(XET::Field) } %}
          @{{m.name.id}}  : {{m.annotation(XET::Field).named_args[:type]}} = {{m.annotation(XET::Field).named_args[:default]}}
        {% end %}
      {% end %}

      def initialize(
        @type = 0xff_u8,
        @version = 0x01_u8,
        @reserved1 = 0x00_u8,
        @reserved2 = 0x00_u8,
        @session_id = 0_u32,
        @sequence = 0_u32,
        @total_packets = 0_u8,
        @current_packet = 0_u8,
        @id = ID,
        @size = 0_u32,
        @message = "",
        {% verbatim do %}
          {% for m in @type.methods.select {|m| m.annotation(XET::Field) } %}
            @{{m.name.id}}  : {{m.annotation(XET::Field).named_args[:type]}} = {{m.annotation(XET::Field).named_args[:default]}},
          {% end %}
        {% end %}
      )
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
end