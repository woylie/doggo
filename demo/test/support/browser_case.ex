defmodule DemoWeb.BrowserCase do
  @moduledoc """
  The case template of the end-to-end tests, ported from the Playwright suite
  in `assets/e2e`. Each module runs once per project of
  `assets/playwright.config.js`.
  """

  use ExUnit.CaseTemplate

  alias Playwright.Test

  def projects do
    [
      Map.put(
        Test.parameters(Playwright.device("Desktop Chrome")),
        :project,
        "chromium"
      ),
      Map.put(
        Test.parameters(
          Keyword.merge(Playwright.device("Desktop Chrome"),
            reduced_motion: :reduce
          )
        ),
        :project,
        "chromium-reduced-motion"
      )
    ]
  end

  using opts do
    quote do
      use Playwright.Case, unquote(opts)

      import DemoWeb.E2EHelpers

      @moduletag :e2e
    end
  end
end
