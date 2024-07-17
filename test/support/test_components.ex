defmodule Doggo.TestComponents do
  @moduledoc """
  Generates components for tests.
  """

  use Phoenix.Component
  import Doggo.Components

  action_bar()
  badge()
end
