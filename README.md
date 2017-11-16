# PhoenixCustomGenerators

**Phoenix Generators with ExMachina and JaSerializer Support**

PhoenixCustomGenerators v1.0 supports Phoenix v1.3 with context and schemas.  

For pre-Phoenix v1.3 support with models, use [PhoenixCustomGenerators v0.1](https://github.com/mikeni/phoenix_custom_generators/tree/pre1-3_generators)

## Installation

Add to your application's mix.deps

```elixir
def deps do
  [
    {:phoenix_custom_generators, "~> 1.0.0"}
  ]
end
```

## Usage

To generate JSON.
```
mix phoenix_custom_generators.gen.json ExampleContext ExampleSchema example_schemas \
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
my_naive_datetime:naive_datetime \
my_utc_datetime:utc_datetime \
my_uuid:uuid \
my_binary:binary \
example_ref_id:references:example_refs
```

To generate JSON-API with JaSerializer.
```
mix phoenix_custom_generators.gen.ja_serializer ExampleContext ExampleSchema example_schemas \
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
my_naive_datetime:naive_datetime \
my_utc_datetime:utc_datetime \
my_uuid:uuid \
my_binary:binary \
example_ref_id:references:example_refs
```


If you want to use ExMachina factories instead of fixtures (default) for generated tests,
add the option --ex-machina-module with the module name,
and the option --ex-machina-path with the location of the factory file.

```
mix phoenix_custom_generators.gen.json ExampleContext ExampleSchema example_schemas \
my_integer:integer \
my_float:float \
--ex-machina-module MyApp.ExMachinaFactory \
--ex-machina-path lib/my_app/ex_machina_factory.ex
```



