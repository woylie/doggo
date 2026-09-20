defmodule Doggo.Storybook.Badge do
  @moduledoc false

  import Doggo.Storybook.Shared

  alias PhoenixStorybook.Stories.Variation

  def dependent_components, do: [:button]

  def variations(opts) do
    [
      %Variation{
        id: :default,
        slots: ["8"]
      },
      %Variation{
        id: :large_count,
        slots: ["+1000"]
      },
      %Variation{
        id: :on_a_button,
        note: """
        In this example, the badge is placed on a button and visually hidden
        text adds context for screen reader users. The button's accessible name
        is "Messages 3 unread".
        """,
        attributes: %{variant: "danger"},
        slots: ["3<span data-visually-hidden> unread</span>"],
        template: """
        <#{button_tag(opts)} type="button">
          #{icon(:mails, opts[:dependent_components])}
          <span data-visually-hidden>Messages</span>
          <.psb-variation/>
        </#{button_tag(opts)}>
        """
      }
    ]
  end

  defp button_tag(opts) do
    if function_name = opts[:dependent_components][:button] do
      ".#{function_name}"
    else
      "button"
    end
  end

  def modifier_variation_base(_id, _name, _value, _opts) do
    %{
      slots: ["8"]
    }
  end
end
