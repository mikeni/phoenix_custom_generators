defmodule Mix.Tasks.PhoenixCustomGenerators.Gen.JaSerializer do
  use Mix.Task

  @shortdoc "Generates a controller and model for a JSON based resource"

  @moduledoc """
  Generates a Phoenix resource.

      mix phoenix.gen.json User users name:string age:integer

  The first argument is the module name followed by
  its plural name (used for resources and schema).

  The generated resource will contain:

    * a schema in web/models
    * a view in web/views
    * a controller in web/controllers
    * a migration file for the repository
    * test files for generated model and controller

  If you already have a model, the generated model can be skipped
  with `--no-model`. Read the documentation for `phoenix.gen.model`
  for more information on attributes and namespaced resources.
  """
  def run(args) do
    switches = [
      binary_id: :boolean, 
      model: :boolean, 
      ex_machina: :string, 
      ecto_calendar_types: :boolean
    ]

    {opts, parsed, _} = OptionParser.parse(args, switches: switches)
    [singular, plural | attrs] = validate_args!(parsed)

    default_opts = Application.get_env(:phoenix, :generators, [])
    opts = Keyword.merge(default_opts, opts)

    attrs   = Mix.PhoenixCustomGenerators.attrs(attrs)
    refs     = references(attrs)
    non_refs = non_references(attrs) ++ [:inserted_at, :updated_at] |> Enum.map(fn(x) -> Atom.to_string(x) end)
    binding = Mix.PhoenixCustomGenerators.inflect(singular)
    path    = binding[:path]
    route   = String.split(path, "/") |> Enum.drop(-1) |> Kernel.++([plural]) |> Enum.join("/")
    binding = binding ++ [
      plural: plural, 
      route: route,
      sample_id: sample_id(opts),
      attrs: attrs, 
      params: Mix.PhoenixCustomGenerators.params(attrs, opts),
      refs: refs,
      non_refs: non_refs,
      ex_machina_module: opts[:ex_machina_module],
      ecto_calendar_types: Keyword.get(opts, :ecto_calendar_types, false)
    ]

    Mix.PhoenixCustomGenerators.check_module_name_availability!(binding[:module] <> "Controller")
    Mix.PhoenixCustomGenerators.check_module_name_availability!(binding[:module] <> "View")

    files = [
      {:eex, "controller.ex",       "web/controllers/#{path}_controller.ex"},
      {:eex, "view.ex",             "web/views/#{path}_view.ex"},
      {:eex, "controller_test.exs", "test/controllers/#{path}_controller_test.exs"},
    ] ++ changeset_view()

    Mix.PhoenixCustomGenerators.copy_from paths(), "priv/templates/phoenix.gen.ja_serializer", "", binding, files

    instructions = """

    Add the resource to your api scope in web/router.ex:

        resources "/#{route}", #{binding[:scoped]}Controller, except: [:new, :edit]
    """
    if opts[:model] != false do
      Mix.Task.run "phoenix_custom_generators.gen.model", ["--instructions", instructions|args]
    else
      Mix.shell.info instructions
    end
  end

  defp sample_id(opts) do
    if Keyword.get(opts, :binary_id, false) do
      Keyword.get(opts, :sample_binary_id, "11111111-1111-1111-1111-111111111111")
    else
      -1
    end
  end

  defp changeset_view do
    if File.exists?("web/views/changeset_view.ex") do
      []
    else
      [{:eex, "changeset_view.ex", "web/views/changeset_view.ex"}]
    end
  end

  defp validate_args!([_, plural | _] = args) do
    cond do
      String.contains?(plural, ":") ->
        raise_with_help()
      plural != Phoenix.Naming.underscore(plural) ->
        Mix.raise "Expected the second argument, #{inspect plural}, to be all lowercase using snake_case convention"
      true ->
        args
    end
  end

  defp validate_args!(_) do
    raise_with_help()
  end

  @spec raise_with_help() :: no_return()
  defp raise_with_help do
    Mix.raise """
    mix phoenix_custom_generators.gen.ja_serializer expects both singular and plural names
    of the generated resource followed by any number of attributes:

        mix phoenix_custom_generators.gen.ja_serializer User users name:string
    """
  end

  defp paths do
    [".", :phoenix_custom_generators]
  end

  defp references(attrs) do
    rv = for {k, v} <- attrs do
      references_strings({k, v})
    end

    rv |> Enum.reject(fn(x) -> is_nil(x) end)
  end

  defp references_strings({k, v}) when is_tuple(v), do: Atom.to_string(k) |> String.replace_trailing("_id", "")
  defp references_strings(_),                       do: nil

  defp non_references(attrs) do
    rv = for {k, v} <- attrs do
      non_references_strings({k, v})
    end

    rv |> Enum.reject(fn(x) -> is_nil(x) end)
  end

  defp non_references_strings({_k, v}) when is_tuple(v), do: nil
  defp non_references_strings({k, _v}),                  do: k


end