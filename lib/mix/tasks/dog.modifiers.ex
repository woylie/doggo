defmodule Mix.Tasks.Dog.Modifiers do
  @shortdoc "Lists all modifier classes"

  @moduledoc """
  Returns a list of all modifier classes.

  ## Usage

  List modifier classes:

      mix dog.modifiers

  Write modifier classes to file:

      mix dog.modifiers -o assets/modifiers.txt
  """

  use Mix.Task

  @parser_opts [
    aliases: [o: :output],
    strict: [output: :string]
  ]

  @impl Mix.Task
  def run(args) do
    case OptionParser.parse(args, @parser_opts) do
      {switches, [], []} ->
        modifiers = list_modifiers()

        if path = Keyword.get(switches, :output) do
          File.write(path, modifiers)
        else
          IO.puts(modifiers)
        end

      _ ->
        IO.puts(@moduledoc)
    end
  end

  defp list_modifiers do
    Doggo.modifier_classes()
    |> Enum.flat_map(fn {_, classes} -> classes end)
    |> Enum.join("\n")
  end
end
