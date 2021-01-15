macro nest(var_name, class_name, field_name, &block)
  {% raise "nest: var_name was not a Call was a #{var_name.class_name}" unless var_name.is_a? Call %}
  {% raise "nest: class_name was not a Path was a #{class_name.class_name}" unless class_name.is_a? Path %}
  {% raise "nest: field_name was not a StringLiteral was a #{field_name.class_name}" unless field_name.is_a? StringLiteral %}
  
  {% begin %}
  {% pp "adding field #{field_name} to ::#{@type} as type ::#{@type}::#{class_name}" %}
  class ::{{@type}}
    field {{var_name}}, ::{{@type}}::{{class_name}}, {{field_name}}


    class {{class_name}}
      include JSON::Serializable


      {% verbatim do %}
      macro finished
        {% pp "Finshed type #{@type}" %}
        {% for m in @type.methods.select {|m| m.annotation(XET::Field) } %}
          @{{m.name.id}}  : {{m.annotation(XET::Field).named_args[:type]}} = {{m.annotation(XET::Field).named_args[:default]}}
          {% pp "adding ivar #{m.name} to ::#{@type}" %}
        {% end %}

        def initialize(
          {% pp "Finshed type.initialize #{@type}" %}
          {% for m in @type.methods.select {|m| m.annotation(XET::Field) } %}
            @{{m.name.id}}  : {{m.annotation(XET::Field).named_args[:type]}} = {{m.annotation(XET::Field).named_args[:default]}},
            {% pp "adding arg #{m.name} to ::#{@type}.initialize" %}
          {% end %}
        )
        end
      end
      {% end %}

      {{ yield }}
    end
  end
  {% end %}
end
