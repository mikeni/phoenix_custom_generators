defmodule Mix.Tasks.PhoenixCustomGenerators.Gen.Json do
  @shortdoc "Generates controller, views, and context for a JSON resource"

  use Mix.Task

  alias Mix.PhoenixCustomGenerators.Context
  alias Mix.Tasks.PhoenixCustomGenerators.Gen

  @doc false
  def run(args) do
    if Mix.Project.umbrella? do
      Mix.raise "mix phoenix_custom_generators.gen.json can only be run inside an application directory"
    end

    {context, schema} = Gen.Context.build(args)
    binding = [context: context, schema: schema]
    paths = Mix.PhoenixCustomGenerators.generator_paths()

    prompt_for_conflicts(context)

    context
    |> copy_new_files(paths, binding)
    |> print_shell_instructions()
  end

  defp prompt_for_conflicts(context) do
    context
    |> files_to_be_generated()
    |> Kernel.++(context_files(context))
    |> Mix.PhoenixCustomGenerators.prompt_for_conflicts()
  end
  defp context_files(%Context{generate?: true} = context) do
    Gen.Context.files_to_be_generated(context)
  end
  defp context_files(%Context{generate?: false}) do
    []
  end

  @doc false
  def files_to_be_generated(%Context{schema: schema, context_app: context_app}) do
    web_prefix = Mix.PhoenixCustomGenerators.web_path(context_app)
    test_prefix = Mix.PhoenixCustomGenerators.web_test_path(context_app)
    
    web_path = to_string(schema.web_path)

    [
      {:eex,     "controller.ex",          Path.join([web_prefix, "controllers", web_path, "#{schema.singular}_controller.ex"])},
      {:eex,     "view.ex",                Path.join([web_prefix, "views", web_path, "#{schema.singular}_view.ex"])},
      {:eex,     "controller_test.exs",    Path.join([test_prefix, "controllers", web_path, "#{schema.singular}_controller_test.exs"])},
      {:new_eex, "changeset_view.ex",      Path.join([web_prefix, "views/changeset_view.ex"])},
      {:new_eex, "fallback_controller.ex", Path.join([web_prefix, "controllers/fallback_controller.ex"])},
    ]
  end

  @doc false
  def copy_new_files(%Context{} = context, paths, binding) do
    files = files_to_be_generated(context)
    Mix.PhoenixCustomGenerators.copy_from paths, "priv/templates/phoenix_custom_generators.gen.json", binding, files
    if context.generate?, do: Gen.Context.copy_new_files(context, paths, binding)

    context
  end

  @doc false
  def print_shell_instructions(%Context{schema: schema, context_app: ctx_app} = context) do
    if schema.web_namespace do
      Mix.shell.info """

      Add the resource to your #{schema.web_namespace} :api scope in #{Mix.PhoenixCustomGenerators.web_path(ctx_app)}/router.ex:

          scope "/#{schema.web_path}", #{inspect Module.concat(context.web_module, schema.web_namespace)} do
            pipe_through :api
            ...
            resources "/#{schema.plural}", #{inspect schema.alias}Controller
          end
      """
    else
      Mix.shell.info """

      Add the resource to your :api scope in #{Mix.PhoenixCustomGenerators.web_path(ctx_app)}/router.ex:

          resources "/#{schema.plural}", #{inspect schema.alias}Controller, except: [:new, :edit]
      """
    end
    if context.generate?, do: Gen.Context.print_shell_instructions(context)
  end
end
