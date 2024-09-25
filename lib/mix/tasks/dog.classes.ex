defmodule Mix.Tasks.Dog.Classes do
  @shortdoc "Lists all component classes"

  @moduledoc """
  Returns a list of all component classes.

  ## Usage

  List all component classes:

      mix dog.modifiers -m MyAppWeb.CoreComponents

  Write classes to file:

      mix dog.classes -m MyAppWeb.CoreComponents -o assets/classes.txt
  """

  use Mix.Task

  @parser_opts [
    aliases: [m: :module, o: :output],
    strict: [module: :string, output: :string]
  ]

  @requirements ["app.config"]

  @impl Mix.Task
  def run(args) do
    with {switches, [], []} <- OptionParser.parse(args, @parser_opts),
         {:ok, module} <- Keyword.fetch(switches, :module) do
      modifiers = list_modifiers(module)

      if path = Keyword.get(switches, :output) do
        File.write(path, modifiers)
      else
        IO.puts(modifiers)
      end
    else
      _ ->
        IO.puts(@moduledoc)
    end
  end

  defp list_modifiers(module) do
    [module]
    |> Module.safe_concat()
    |> Doggo.classes()
    |> Enum.join("\n")
  end
end
