annotation XET::Field
end

macro field?(var_name, type_node, field_name)
  {% raise "field?: var_name was not a Call was a #{var_name.class_name}" unless var_name.is_a? Call %}
  {% raise "field?: type_node was not a Path was a #{type_node.class_name}" unless type_node.is_a? Path %}
  {% raise "field?: field_name was not a StringLiteral was a #{field_name.class_name}" unless field_name.is_a? StringLiteral %}

  class ::{{@type}}
    @[::JSON::Field(key: {{ field_name }})]
    @{{ var_name.id }} : {{ type_node }}?

    @[::XET::Field(type: {{ type_node }}?, default: nil)] # Put an annotation to tell the `command` macro what the default value should be for the `initialize` method
    def {{ var_name.id }} : {{ type_node }}?
      @{{ var_name.id }}
    end

    def {{ var_name.id }}=(other : {{ type_node }}?)
      @{{ var_name.id }} = other
    end
  end
  
end

macro field(var_name, type_node, field_name, default = nil)
  {% raise "field: var_name was not a Call was a #{var_name.class_name}" unless var_name.is_a? Call %}
  {% raise "field: type_node was not a Path was a #{type_node.class_name}" unless type_node.is_a? Path %}
  {% raise "field: field_name was not a StringLiteral was a #{field_name.class_name}" unless field_name.is_a? StringLiteral %}

  class ::{{@type}}
    {% if default %}

    @[::JSON::Field(key: {{ field_name }})]
    @{{ var_name.id }} : {{ type_node }}  = {{ default }}

    @[::XET::Field(type: {{ type_node }}, default: {{ default }})] # Put an annotation to tell the `command` macro what the default value should be for the `initialize` method. Kinda can;t believe it works this way :)
    def {{ var_name.id }} : {{ type_node }}
      @{{ var_name.id }}
    end
    
    def {{ var_name.id }}=(other : {{ type_node }})
      @{{ var_name.id }} = other
    end

    {% else %}

    @[::JSON::Field(key: {{ field_name }})]
    @{{ var_name.id }} : {{ type_node }}  = {{ type_node }}.new

    @[::XET::Field(type: {{ type_node }}, default: {{ type_node }}.new)] # Put an annotation to tell the `command` macro what the default value should be for the `initialize` method. Kinda can;t believe it works this way :)
    def {{ var_name.id }} : {{ type_node }}
      @{{ var_name.id }}
    end
    
    def {{ var_name.id }}=(other : {{ type_node }})
      @{{ var_name.id }} = other
    end
    {% end %}
  end
end