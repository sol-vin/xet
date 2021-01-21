# This macro makes a command using scaffolding in conjunction with `nest` and `field`.
# Allows you to quickly make and store XET::Message subclasses undet XET::Command, making cleaner and DRYer code.
macro command(class_path, id, build_message = true, &block)
  {% raise "command: class_path was not a Path" unless class_path.is_a? Path %}
  {% raise "command: id was not a NumberLiteral" unless id.is_a? NumberLiteral %}


  {% begin %}
  class ::XET::Command::{{class_path.id}} < XET::Message
    include JSON::Serializable
    ID = {{id}}_u16

    # We have to define these variables or we are going to get invalid memory access.
    macro finished
      @type = XET::Message::Defaults::TYPE
      @version = XET::Message::Defaults::VERSION
      @reserved1 = XET::Message::Defaults::RESERVED1
      @reserved2 = XET::Message::Defaults::RESERVED2
      @session_id = XET::Message::Defaults::SESSION_ID
      @sequence = XET::Message::Defaults::SEQUENCE
      @total_packets = XET::Message::Defaults::TOTAL_PACKETS
      @current_packet = XET::Message::Defaults::CURRENT_PACKET
      @id = ID
      @size = XET::Message::Defaults::SIZE
      @message = ""

      def initialize(
        # This enables all the XET::Message variables to be changed from initialize
        @type = XET::Message::Defaults::TYPE,
        @version = XET::Message::Defaults::VERSION,
        @reserved1 = XET::Message::Defaults::RESERVED1,
        @reserved2 = XET::Message::Defaults::RESERVED2,
        @session_id = XET::Message::Defaults::SESSION_ID,
        @sequence = XET::Message::Defaults::SEQUENCE,
        @total_packets = XET::Message::Defaults::TOTAL_PACKETS,
        @current_packet = XET::Message::Defaults::CURRENT_PACKET,
        @id = ID,
        @size = XET::Message::Defaults::SIZE,
        @message = "",
        # This adds all the fields to the initialize args.
        {% verbatim do %}
          {% for m in @type.methods.select {|m| m.annotation(XET::Field) } %}
            @{{m.name.id}}  : {{m.annotation(XET::Field).named_args[:type]}} = {{m.annotation(XET::Field).named_args[:default]}},
          {% end %}
        {% end %}
      )
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
        {% if (block && build_message)%}
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