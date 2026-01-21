defmodule Doggo.MixProject do
  use Mix.Project

  @source_url "https://github.com/woylie/doggo"
  @version "0.12.0"

  def project do
    [
      app: :doggo,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
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

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def cli do
    [
      preferred_envs: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.github": :test,
        "coveralls.html": :test,
        "coveralls.json": :test
      ]
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
      {:credo, "1.7.15", runtime: false, only: [:dev, :test]},
      {:dialyxir, "1.4.7", runtime: false, only: [:dev, :test]},
      {:ex_doc, "0.40.0", only: :dev, runtime: false},
      {:excoveralls, "0.18.5", runtime: false, only: [:test]},
      {:floki, "0.38.0", only: :test},
      {:gettext, "~> 0.20 or ~> 0.26 or ~> 1.0", optional: true},
      {:jason, "1.4.4", only: [:dev, :test]},
      {:lazy_html, "0.1.8", only: :test},
      {:makeup_diff, "0.1.1", only: :dev},
      {:phoenix_live_view, "~> 1.1.0"},
      {:phoenix_storybook, "~> 0.9"},
      {:tzdata, "1.1.3", only: [:test]}
    ]
  end

  defp description do
    """
    Headless UI components for Phoenix
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
      files: ~w(lib .formatter.exs mix.exs CHANGELOG.md README* LICENSE*)
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md", "CHANGELOG.md"],
      source_ref: @version,
      skip_undefined_reference_warnings_on: ["CHANGELOG.md"],
      groups_for_docs: [
        Buttons: &(&1[:type] == :buttons),
        Data: &(&1[:type] == :data),
        Feedback: &(&1[:type] == :feedback),
        Form: &(&1[:type] == :form),
        Layout: &(&1[:type] == :layout),
        Media: &(&1[:type] == :media),
        Menu: &(&1[:type] == :menu),
        Miscellaneous: &(&1[:type] == :miscellaneous),
        Navigation: &(&1[:type] == :navigation),
        JS: &(&1[:type] == :js)
      ]
    ]
  end
end
