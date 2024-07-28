defmodule Demo.MixProject do
  use Mix.Project

  def project do
    [
      app: :demo,
      version: version(),
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Demo.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.7.10"},
      {:phoenix_html, "~> 4.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 1.0.0-rc.0"},
      {:floki, ">= 0.30.0", only: :test},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      {:gettext, "~> 0.20"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.5"},
      {:phoenix_storybook, "~> 0.6.0"},
      {:heroicons, "~> 0.5.3"},
      {:doggo, path: ".."},
      {:tzdata, "~> 1.1"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "assets.setup", "assets.build"],
      "assets.setup": ["cmd pnpm --dir assets install"],
      "assets.build": ["cmd pnpm --dir assets build:dev"],
      "assets.deploy": ["cmd pnpm --dir assets build:prod", "phx.digest"]
    ]
  end

  defp version do
    with {str, _} <- System.cmd("git", ["describe", "--tags", "--always"]),
         str = String.trim(str),
         {:ok, version} <- Version.parse(str) do
      version
      |> Map.update!(:pre, fn
        nil ->
          nil

        [pre] when is_binary(pre) ->
          [commits | _] = String.split(pre, "-")
          [commits]
      end)
      |> to_string()
    else
      _ -> "0.1.0"
    end
  end
end
