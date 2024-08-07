defmodule Mix.Tasks.Dog.Gen.Stories do
  @shortdoc "Generates Phoenix Storybook modules for all configured components"

  @moduledoc """
  Generates Phoenix Storybook modules for all configured components.

  ## Usage

  Write stories for all configured components:

      mix dog.gen.stories -m MyAppWeb.CoreComponents -o storybook -a

  Write the story for a single component:

      mix dog.gen.stories -m MyAppWeb.CoreComponents -o storybook -c button

  ## Options

  - -m, --module: The module where the Doggo components are compiled.
  - -o, --output: The Storybook folder.
  - -c, --component: The name of the component.
  - -a, --all: Write stories for all configured components.
  - -f, --force: Force folder creation and overwrite existing stories.
  """

  use Mix.Task

  @switches [
    aliases: [a: :all, c: :component, f: :force, m: :module, o: :output],
    strict: [
      all: :boolean,
      component: :string,
      force: :boolean,
      module: :string,
      output: :string
    ]
  ]

  @requirements ["app.config"]

  @impl Mix.Task
  def run(args) do
    {opts, []} = OptionParser.parse!(args, @switches)

    with {:ok, module} <- Keyword.fetch(opts, :module),
         {:ok, path} <- Keyword.fetch(opts, :output) do
      component = component_option(opts)
      force = Keyword.get(opts, :force, false)
      ensure_folder_exists(path, force: force)
      module = Module.safe_concat([module])
      components = Enum.to_list(module.__dog_components__())

      if component == :all do
        write_stories(components, module, path, force: force)
      else
        component = find_component(components, component)
        write_stories([component], module, path, force: force)
      end
    else
      _ ->
        IO.puts(@moduledoc)
    end
  end

  defp component_option(opts) do
    all = Keyword.get(opts, :all, false)
    component = Keyword.get(opts, :component)

    if all && component do
      IO.puts("Error: expected either --all or --component, got both.")
      exit({:shutdown, 1})
    end

    if !all && is_nil(component) do
      IO.puts("Error: expected either --all or --component, got none.")
      exit({:shutdown, 1})
    end

    if all, do: :all, else: component
  end

  defp find_component(components, component) when is_binary(component) do
    result =
      Enum.find(components, fn {name, _info} ->
        Atom.to_string(name) == component
      end)

    if result do
      result
    else
      IO.puts("Error: Component '#{component}' not found.")
      exit({:shutdown, 1})
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

    if template = Doggo.Storybook.story_template(module, name) do
      folder_path = Path.join([base_path, Atom.to_string(type)])
      File.mkdir_p!(folder_path)
      file_path = Path.join([folder_path, "#{name}.story.exs"])
      exists? = File.exists?(file_path)

      cond do
        !exists? || opts[:force] ->
          write_file(file_path, template)
          write_stories(rest, module, base_path, opts)

        exists? && opts[:skip_all] ->
          write_stories(rest, module, base_path, opts)

        true ->
          handle_existing_file(
            file_path,
            template,
            rest,
            module,
            base_path,
            opts
          )
      end
    else
      write_stories(rest, module, base_path, opts)
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
        write_file(file_path, template)
        write_stories(rest, module, base_path, opts)

      :overwrite_all ->
        write_file(file_path, template)
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

  defp write_file(file_path, template) do
    {formatter, _} = Mix.Tasks.Format.formatter_for_file(file_path)
    File.write!(file_path, formatter.(template))
    IO.puts("Story written to #{file_path}.")
  end
end
