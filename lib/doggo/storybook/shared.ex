defmodule Doggo.Storybook.Shared do
  @moduledoc false

  def icon(name, dependent_components) do
    if function_name = dependent_components[:icon] do
      "<.#{function_name}>#{icon_svg(name)}</.#{function_name}>"
    else
      icon_svg(name)
    end
  end

  def icon_svg(:add) do
    """
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
      class="lucide lucide-plus"
    >
      <path d="M5 12h14"/>
      <path d="M12 5v14"/>
    </svg>
    """
  end
end
