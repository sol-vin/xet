macro command(class_path, id, &block)
  class ::XET::Command::{{class_path.id}} < XET::Message
    include JSON::Serializable
    ID = {{id}}_u16

    def initialize
    end

    def self.from_msg(msg : XET::Message) : ::XET::Command::{{class_path.id}}
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
    end

    {{ yield }}
  end
end