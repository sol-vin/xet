macro field?(var_name, type_node, field_name)
  @[JSON::Field(key: {{ field_name }})]
  property {{ var_name.id }} : {{ type_node }}?
end

macro field(var_name, type_node, field_name, default)
  @[JSON::Field(key: {{ field_name }})]
  property {{ var_name.id }} : {{ type_node }} = {{ default }}
end