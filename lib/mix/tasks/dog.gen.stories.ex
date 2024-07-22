defmodule Mix.Tasks.Dog.Gen.Stories do
  @shortdoc "Generates Phoenix Storybook modules for all configured components"

  @moduledoc """
  Generates Phoenix Storybook modules for all configured components.

  ## Usage

      mix dog.gen.stories -m MyAppWeb.CoreComponents -o storybook

  ## Options

  - --module/-m: The module where the Doggo components are compiled.
  - --output/-o: The Storybook folder.
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
      ensure_folder_exists(path)
      module = Module.safe_concat([module])
      components = module.__dog_components__()
      Enum.each(components, &write_story(&1, module, path))
    else
      _ ->
        IO.puts(@moduledoc)
    end
  end

  defp ensure_folder_exists(path) do
    if File.exists?(path) do
      if File.dir?(path) do
        :ok
      else
        IO.puts("Error: Output path is not a directory.")
        exit({:shutdown, 1})
      end
    else
      IO.puts("Output directory '#{path}' does not exist.")
      prompt_create_directory(path)
    end
  end

  defp prompt_create_directory(path) do
    case IO.gets("Do you want to create the directory? (y/n)\n") do
      "y\n" -> File.mkdir_p!(path)
      _ -> exit({:shutdown, 1})
    end
  end

  defp write_story({name, info}, module, base_path) do
    type = Keyword.fetch!(info, :type)
    folder_path = Path.join([base_path, Atom.to_string(type)])
    File.mkdir_p!(folder_path)
    file_path = Path.join([folder_path, "#{name}.story.exs"])
    template = Doggo.Storybook.story_template(module, name)
    File.write!(file_path, template)
    IO.puts("Story written to #{file_path}")
  end
end
