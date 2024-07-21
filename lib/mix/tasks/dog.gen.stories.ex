defmodule Mix.Tasks.Dog.Gen.Stories do
  @shortdoc "Generates Phoenix Storybook modules for all configured components"

  @moduledoc """
  Generates Phoenix Storybook modules for all configured components.

  ## Usage

      mix dog.gen.stories -m MyAppWeb.CoreComponents -o storybook
  """

  use Mix.Task

  @switches [
    aliases: [m: :module, o: :output],
    strict: [module: :string, output: :string]
  ]

  @requirements ["app.config"]

  @impl Mix.Task
  def run(args) do
    {opts, []} = OptionParser.parse!(args, @switches)

    with {:ok, module} <- Keyword.fetch(opts, :module),
         {:ok, path} <- Keyword.fetch(opts, :output) do
      module = Module.safe_concat([module])
      components = module.__dog_components__()
      Enum.each(components, &write_story(&1, module, path))
    else
      _ ->
        IO.puts(@moduledoc)
    end
  end

  defp write_story({name, _}, module, base_path) do
    folder_path = Path.join([base_path, "components"])
    File.mkdir_p!(folder_path)
    file_path = Path.join([folder_path, "#{name}.story.exs"])
    template = Doggo.Storybook.story_template(module, name)
    File.write!(file_path, template)
    IO.puts("Story written to #{file_path}")
  end
end
