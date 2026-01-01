defmodule DemoWeb.Icons do
  @moduledoc false
  use Phoenix.Component

  def names do
    ["info"]
  end

  # For simulating an icon component with icon_module/icon_fun options
  def render(%{name: "info"} = assigns) do
    ~H"""
    <.info />
    """
  end

  def info(assigns) do
    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width="24"
      height="24"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      stroke-width="2"
      stroke-linecap="round"
      stroke-linejoin="round"
    >
      <circle cx="12" cy="12" r="10" /><path d="M12 16v-4" /><path d="M12 8h.01" />
    </svg>
    """
  end
end
