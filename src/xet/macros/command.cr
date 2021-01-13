macro command(class_path, id, &block)
  class ::XET::Command::{{class_path.id}} < XET::Message
    include JSON::Serializable
    ID = {{id}}_u16

    def initialize
    end

    {{ yield }}
  end
end