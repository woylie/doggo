defmodule Doggo.MixProject do
  use Mix.Project

  @source_url "https://github.com/woylie/doggo"
  @version "0.1.2"

  def project do
    [
      app: :doggo,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.github": :test,
        "coveralls.html": :test,
        "coveralls.json": :test
      ],
      dialyzer: [
        list_unused_filters: true,
        plt_add_apps: [:ex_unit, :mix],
        plt_file: {:no_warn, ".plts/doggo.plt"}
      ],
      name: "Doggo",
      source_url: @source_url,
      homepage_url: @source_url,
      description: description(),
      package: package(),
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.6", runtime: false, only: [:dev, :test]},
      {:dialyxir, "~> 1.2", runtime: false, only: [:dev, :test]},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:excoveralls, "~> 0.18.0", runtime: false, only: [:test]},
      {:floki, ">= 0.30.0", only: :test},
      {:gettext, "~> 0.20", optional: true},
      {:jason, "~> 1.0", only: [:dev, :test]},
      {:phoenix_live_view, "~> 0.20.0"}
    ]
  end

  defp description do
    """
    Collection of unstyled Phoenix components
    """
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Changelog" => @source_url <> "/blob/main/CHANGELOG.md",
        "Sponsor" => "https://github.com/sponsors/woylie"
      },
      files: ~w(lib priv .formatter.exs mix.exs CHANGELOG.md README* LICENSE*)
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md", "CHANGELOG.md"],
      logo: "doggo.png",
      source_ref: @version,
      skip_undefined_reference_warnings_on: ["CHANGELOG.md"],
      groups_for_functions: [
        Components: &(&1[:type] == :component),
        Layouts: &(&1[:type] == :layout)
      ]
    ]
  end
end
