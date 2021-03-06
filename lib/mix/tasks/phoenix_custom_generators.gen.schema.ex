defmodule Mix.Tasks.PhoenixCustomGenerators.Gen.Schema do
  @shortdoc "Generates an Ecto schema and migration file"

  use Mix.Task

  alias Mix.PhoenixCustomGenerators.Schema

  @switches [migration: :boolean, binary_id: :boolean, table: :string,
             web: :string, ex_machina_module: :string, ex_machina_path: :string]

  @doc false
  def run(args) do
    if Mix.Project.umbrella?() do
      Mix.raise "mix phx.gen.schema can only be run inside an application directory"
    end

    schema = build(args, [])
    paths = Mix.PhoenixCustomGenerators.generator_paths()

    prompt_for_conflicts(schema)

    schema
    |> copy_new_files(paths, schema: schema)
    |> print_shell_instructions()
  end

  defp prompt_for_conflicts(schema) do
    schema
    |> files_to_be_generated()
    |> Mix.PhoenixCustomGenerators.prompt_for_conflicts()
  end

  @doc false
  def build(args, parent_opts, help \\ __MODULE__) do
    {schema_opts, parsed, _} = OptionParser.parse(args, switches: @switches)
    [schema_name, plural | attrs] = validate_args!(parsed, help)
    opts = Keyword.merge(parent_opts, schema_opts)
    schema = Schema.new(schema_name, plural, attrs, opts)

    schema
  end

  @doc false
  def files_to_be_generated(%Schema{} = schema) do
    [{:eex, "schema.ex", schema.file}]
  end

  @doc false
  def copy_new_files(%Schema{context_app: ctx_app} = schema, paths, binding) do
    files = files_to_be_generated(schema)
    Mix.PhoenixCustomGenerators.copy_from(paths,"priv/templates/phoenix_custom_generators.gen.schema", binding, files)

    case Keyword.fetch(schema.opts, :ex_machina_path) do
      {:ok, ex_machina_path} -> inject_ex_machina_factory(paths, ex_machina_path, binding)
      :error -> nil
    end  

    if schema.migration? do
      migration_path = Mix.PhoenixCustomGenerators.context_app_path(ctx_app, "priv/repo/migrations/#{timestamp()}_create_#{schema.table}.exs")
      Mix.PhoenixCustomGenerators.copy_from paths, "priv/templates/phoenix_custom_generators.gen.schema", binding, [
        {:eex, "migration.exs", migration_path},
      ]
    end

    schema
  end

  defp inject_ex_machina_factory(paths, ex_machina_path, binding) do
    unless File.exists?(ex_machina_path) do
      Mix.Generator.create_file(ex_machina_path, Mix.PhoenixCustomGenerators.eval_from(paths, "priv/templates/phoenix_custom_generators.gen.schema/ex_machina.ex", binding))
    end

    content_to_inject = Mix.PhoenixCustomGenerators.eval_from(paths, "priv/templates/phoenix_custom_generators.gen.schema/ex_machina_factory.ex", binding)
    file = File.read!(ex_machina_path)
    if String.contains?(file, content_to_inject) do
      :ok
    else
      Mix.shell.info([:green, "* injecting ", :reset, Path.relative_to_cwd(ex_machina_path)])

      file
      |> String.trim_trailing()
      |> String.trim_trailing("end")
      |> EEx.eval_string(binding)
      |> Kernel.<>(content_to_inject)
      |> Kernel.<>("end\n")
      |> write_file(ex_machina_path)
    end
  end

  defp write_file(content, file) do
    File.write!(file, content)
  end

  @doc false
  def print_shell_instructions(%Schema{} = schema) do
    if schema.migration? do
      Mix.shell.info """

      Remember to update your repository by running migrations:

          $ mix ecto.migrate
      """
    end
  end

  @doc false
  def validate_args!([schema, plural | _] = args, help) do
    cond do
      not Schema.valid?(schema) ->
        help.raise_with_help "Expected the schema argument, #{inspect schema}, to be a valid module name"
      String.contains?(plural, ":") or plural != Phoenix.Naming.underscore(plural) ->
        help.raise_with_help "Expected the plural argument, #{inspect plural}, to be all lowercase using snake_case convention"
      true ->
        args
    end
  end
  def validate_args!(_, help) do
    help.raise_with_help "Invalid arguments"
  end

  @doc false
  @spec raise_with_help(String.t) :: no_return()
  def raise_with_help(msg) do
    Mix.raise """
    #{msg}

    mix phx.gen.schema expects both a module name and
    the plural of the generated resource followed by
    any number of attributes:

        mix phx.gen.schema Blog.Post blog_posts title:string
    """
  end

  defp timestamp do
    {{y, m, d}, {hh, mm, ss}} = :calendar.universal_time()
    "#{y}#{pad(m)}#{pad(d)}#{pad(hh)}#{pad(mm)}#{pad(ss)}"
  end
  defp pad(i) when i < 10, do: << ?0, ?0 + i >>
  defp pad(i), do: to_string(i)
end
