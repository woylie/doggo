defmodule Doggo.FixtureIcons do
  @moduledoc false
  use Phoenix.Component

  def info(assigns) do
    ~H"""
    <svg class="info"></svg>
    """
  end
end
