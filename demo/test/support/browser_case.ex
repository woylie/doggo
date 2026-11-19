defmodule DemoWeb.BrowserCase do
  @moduledoc """
  The case template of the end-to-end tests. Each module runs once per
  project (`projects/0`): Desktop Chrome, with and without reduced motion.
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
