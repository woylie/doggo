defmodule Mix.Tasks.Dog.Modifiers do
  @shortdoc "Lists all modifier classes"

  @moduledoc """
  Returns a list of all modifier classes.

  ## Usage

  List modifier classes:

      mix dog.modifiers

  Write modifier classes to file:

      mix dog.modifiers -m MyAppWeb.CoreComponents -o assets/modifiers.txt
  """

  use Mix.Task

  @parser_opts [
    aliases: [m: :module, o: :output],
    strict: [module: :string, output: :string]
  ]

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
    |> Doggo.modifier_classes()
    |> Enum.join("\n")
  end
end
