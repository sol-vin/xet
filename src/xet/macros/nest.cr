macro nest(var_name, class_name, field_name, &block)
  {% raise "nest: var_name was not a Call was a #{var_name.class_name}" unless var_name.is_a? Call %}
  {% raise "nest: class_name was not a Path was a #{class_name.class_name}" unless class_name.is_a? Path %}
  {% raise "nest: field_name was not a StringLiteral was a #{field_name.class_name}" unless field_name.is_a? StringLiteral %}
  
  {% begin %}
  field {{var_name}}, ::{{@type}}::{{class_name}}, {{field_name}}
  

  class ::{{@type}}::{{class_name}}
    include JSON::Serializable

    macro finished
      {% for m in @type.methods.select {|m| m.annotation(XET::Field) } %}
        @{{m.name.id}}  : {{m.annotation(XET::Field).named_args[:type]}} = {{m.annotation(XET::Field).named_args[:default]}}
      {% end %}

      def initialize(
        {% verbatim do %}
          {% for m in @type.methods.select {|m| m.annotation(XET::Field) } %}
            @{{m.name.id}}  : {{m.annotation(XET::Field).named_args[:type]}} = {{m.annotation(XET::Field).named_args[:default]}},
          {% end %}
        {% end %}
      )
      end
    end

    {{ yield }}
  end
  {% end %}
end
