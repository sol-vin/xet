annotation XET::Field
end

macro field?(var_name, type_node, field_name)
  @[JSON::Field(key: {{ field_name }})]
  @{{ var_name.id }} : {{ type_node }}?

  @[XET::Field(default: nil)] # Put an annotation to tell the `command` macro what the default value should be for the `initialize` method
  def {{ var_name.id }} : {{ type_node }}?
    @{{ var_name.id }}
  end

  def {{ var_name.id }}=(other : {{ type_node }}?)
    @{{ var_name.id }} = other
  end
end

macro field(var_name, type_node, field_name, default)
  @[JSON::Field(key: {{ field_name }})]
  @{{ var_name.id }} : {{ type_node }}  = {{ default }}

  @[XET::Field(default: {{ default }})] # Put an annotation to tell the `command` macro what the default value should be for the `initialize` method. Kinda can;t believe it works this way :)
  def {{ var_name.id }} : {{ type_node }}
    @{{ var_name.id }}
  end

  def {{ var_name.id }}=(other : {{ type_node }})
    @{{ var_name.id }} = other
  end
end