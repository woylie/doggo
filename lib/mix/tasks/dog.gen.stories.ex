defmodule Mix.Tasks.Dog.Gen.Stories do
  @shortdoc "Generates Phoenix Storybook modules for all configured components"

  @moduledoc """
  Generates Phoenix Storybook modules for all configured components.

  ## Usage

      mix dog.gen.stories -m MyAppWeb.CoreComponents -o storybook

  ## Options

  - -m, --module: The module where the Doggo components are compiled.
  - -o, --output: The Storybook folder.
  - -f, --force: Force folder creation and overwrite existing stories.
  """

  use Mix.Task

  @switches [
    aliases: [f: :force, m: :module, o: :output],
    strict: [force: :boolean, module: :string, output: :string]
  ]

  @requirements ["app.config"]

  @impl Mix.Task
  def run(args) do
    {opts, []} = OptionParser.parse!(args, @switches)

    with {:ok, module} <- Keyword.fetch(opts, :module),
         {:ok, path} <- Keyword.fetch(opts, :output) do
      force = Keyword.get(opts, :force, false)
      ensure_folder_exists(path, force: force)
      module = Module.safe_concat([module])

      module.__dog_components__()
      |> Enum.to_list()
      |> write_stories(module, path, force: force)
    else
      _ ->
        IO.puts(@moduledoc)
    end
  end

  defp ensure_folder_exists(path, opts) do
    if File.exists?(path) do
      if File.dir?(path) do
        :ok
      else
        IO.puts("Error: Output path is not a directory.")
        exit({:shutdown, 1})
      end
    else
      if opts[:force] do
        File.mkdir_p!(path)
        IO.puts("Directory '#{path}' created.")
      else
        IO.puts("Output directory '#{path}' does not exist.")
        prompt_create_directory(path)
      end
    end
  end

  defp prompt_create_directory(path) do
    case IO.gets("Do you want to create the directory? (y/n)\n") do
      "y\n" ->
        File.mkdir_p!(path)
        IO.puts("Directory '#{path}' created.")

      _ ->
        exit({:shutdown, 1})
    end
  end

  defp write_stories([], _, _, _), do: :ok

  defp write_stories([{name, info} | rest], module, base_path, opts) do
    type = Keyword.fetch!(info, :type)
    template = Doggo.Storybook.story_template(module, name)

    folder_path = Path.join([base_path, Atom.to_string(type)])
    File.mkdir_p!(folder_path)
    file_path = Path.join([folder_path, "#{name}.story.exs"])
    exists? = File.exists?(file_path)

    cond do
      !exists? || opts[:force] ->
        File.write!(file_path, template)
        IO.puts("Story written to #{file_path}.")
        write_stories(rest, module, base_path, opts)

      exists? && opts[:skip_all] ->
        write_stories(rest, module, base_path, opts)

      true ->
        handle_existing_file(file_path, template, rest, module, base_path, opts)
    end
  end

  defp handle_existing_file(
         file_path,
         template,
         rest,
         module,
         base_path,
         opts
       ) do
    IO.puts("\nFile '#{file_path}' already exists.")

    case prompt_overwrite() do
      :overwrite ->
        File.write!(file_path, template)
        IO.puts("Story written to #{file_path}")
        write_stories(rest, module, base_path, opts)

      :overwrite_all ->
        File.write!(file_path, template)
        IO.puts("Story written to #{file_path}")
        opts = Keyword.put(opts, :force, true)
        write_stories(rest, module, base_path, opts)

      :skip ->
        write_stories(rest, module, base_path, opts)

      :skip_all ->
        opts = Keyword.put(opts, :skip_all, true)
        write_stories(rest, module, base_path, opts)

      :quit ->
        exit({:shutdown, 1})
    end
  end

  defp prompt_overwrite do
    case IO.gets(
           "Choose an action: [o] overwrite, [a] overwrite all, [s] skip, [x] skip all, [q] quit\n"
         ) do
      "o\n" -> :overwrite
      "a\n" -> :overwrite_all
      "s\n" -> :skip
      "x\n" -> :skip_all
      "q\n" -> :quit
      _ -> prompt_overwrite()
    end
  end
end
