defmodule Doggo.HookComponents do
  @moduledoc """
  Builds the components that ship a JavaScript hook.

  The rendered markup is written to `assets/test/fixtures` so that the hook
  tests run against what the component actually emits.
  """

  use Doggo.Components
  use Phoenix.Component

  build_accordion()
  build_action_bar()
  build_carousel()
  build_menu()
  build_menu_bar()
  build_menu_button()
  build_menu_item()
  build_menu_item_checkbox()
  build_menu_item_radio_group()
  build_tabs()
  build_toolbar()
  build_tooltip()
end
