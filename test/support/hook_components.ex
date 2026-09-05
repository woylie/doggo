defmodule Doggo.HookComponents do
  @moduledoc """
  Builds the components that ship a JavaScript hook.

  The rendered markup is written to `assets/test/fixtures` so that the hook
  tests run against what the component actually emits.
  """

  use Doggo.Components
  use Phoenix.Component

  build_carousel()
  build_tabs()
end
