# PhoenixCustomGenerators

**Phoenix Generators with ExMachina and JaSerializer Support**

## Installation

Add to your application's mix.deps

```elixir
def deps do
  [
    {:phoenix_custom_generators, "~> 0.0.1"}
  ]
end
```

## Usage

```
mix phoenix_custom_generators.gen.json ExampleModel example_models \
my_integer:integer \
my_float:float \
my_decimal:decimal \
my_boolean:boolean \
my_map:map \
my_string:string \
my_array:array:string \
my_text:string \
my_date:date \
my_time:time \
my_datetime:datetime \
my_uuid:uuid \
my_binary:binary
```

If you want to use ExMachina factories instead of fixtures (default) for generated tests,
add the option --ex-machina-module with the module name as the value.

```
mix phoenix_custom_generators.gen.json ExampleModel example_models \
my_integer:integer \
my_float:float \
--ex-machina-module MyApp.ExMachinaFactory
```

If you are using ecto version before v2.1 and using Ecto.Date|Time types,
add the option --ecto-calendar-types, otherwise you are using Elixir native Date|Time.

```
mix phoenix_custom_generators.gen.json ExampleModel example_models \
my_integer:integer \
my_float:float \
--ecto-calendar-types
```

