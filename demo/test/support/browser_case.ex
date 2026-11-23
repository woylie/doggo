defmodule DemoWeb.BrowserCase do
  @moduledoc """
  The case template of the end-to-end tests. Each module runs once per
  project (`projects/0`): Desktop Chrome, with and without reduced motion.
  E2E_PROJECT picks one of them by name ("chromium" or
  "chromium-reduced-motion"); the default is both.
  """

  use ExUnit.CaseTemplate

  alias Playwright.Test

  def projects do
    projects =
      case System.get_env("E2E_PROJECT") do
        nil ->
          all_projects()

        name ->
          case Enum.filter(all_projects(), &(&1[:name] == name)) do
            [] -> raise ~s(E2E_PROJECT: unknown project "#{name}")
            projects -> projects
          end
      end

    Enum.map(projects, &Test.parameters/1)
  end

  defp all_projects do
    [
      [name: "chromium"] ++ Playwright.device("Desktop Chrome"),
      [name: "chromium-reduced-motion"] ++
        Playwright.device("Desktop Chrome") ++ [reduced_motion: :reduce]
    ]
  end

  using opts do
    opts =
      Keyword.put_new(
        opts,
        :parameterize,
        quote(do: DemoWeb.BrowserCase.projects())
      )

    quote do
      use Playwright.Case, unquote(opts)

      import DemoWeb.E2EHelpers

      @moduletag :e2e
    end
  end
end
