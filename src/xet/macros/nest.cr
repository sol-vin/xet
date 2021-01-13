macro nest(var_name, class_name, field_name, &block)
  field {{var_name}}, {{class_name}}, {{field_name}}, default: {{class_name}}.new

  class {{class_name}}
    include JSON::Serializable
    def initialize
    end

    {{ yield }}
  end
end