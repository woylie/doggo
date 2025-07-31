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
      deps: deps(),
      compilers: [:phoenix_live_view] ++ Mix.compilers(),
      releases: [
        demo: [
          strip_beams: [
            keep: ["Docs"]
          ]
        ]
      ],
      dialyzer: [
        list_unused_filters: true,
        plt_add_apps: [:ex_unit, :mix],
        plt_file: {:no_warn, ".plts/demo.plt"}
      ]
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
      {:phoenix, "== 1.7.21"},
      {:phoenix_html, "== 4.2.1"},
      {:phoenix_live_reload, "== 1.6.0", only: :dev},
      {:phoenix_live_view, "== 1.1.1"},
      {:lazy_html, ">= 0.0.0", only: :test},
      {:floki, "== 0.37.1", only: :test},
      {:esbuild, "== 0.9.0", runtime: Mix.env() == :dev},
      {:gettext, "== 0.26.2"},
      {:jason, "== 1.4.4"},
      {:bandit, "== 1.6.11"},
      {:phoenix_storybook, "== 0.9.1"},
      {:heroicons, "== 0.5.6"},
      {:doggo, path: ".."},
      {:tzdata, "== 1.1.3"},
      {:credo, "== 1.7.12", runtime: false, only: [:dev, :test]},
      {:dialyxir, "== 1.4.5", runtime: false, only: [:dev, :test]}
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
      "assets.setup": ["cmd pnpm --dir assets install --force"],
      "assets.build": ["cmd pnpm --dir assets build:dev"],
      "assets.deploy": ["cmd pnpm --dir assets build:prod", "phx.digest"]
    ]
  end

  defp version do
    if version = System.get_env("VERSION") do
      version
    else
      version_from_git()
    end
  end

  defp version_from_git do
    with {str, _} <- System.cmd("git", ["describe", "--tags", "--always"]),
         str = String.trim(str),
         {:ok, version} <- Version.parse(str) do
      to_string(version)
    else
      _ -> "0.1.0"
    end
  end
end
