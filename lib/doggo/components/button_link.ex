defmodule Doggo.Components.ButtonLink do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    Renders a link (`<a>`) that has the role and style of a button.

    Use this component when you need to style a link to a different page or a
    specific section within the same page as a button.

    To perform an action on the same page, including toggles and
    revealing/hiding elements, you should always use a real button instead. See
    `button/1`, `toggle_button/1`, and `disclosure_button/1`.
    """
  end

  @impl true
  def usage do
    """
    ```heex
    <.button_link patch={~p"/confirm"}>
      Confirm
    </.button_link>

    <.button_link navigate={~p"/registration"}>
      Registration
    </.button_link>
    ```
    """
  end

  @impl true
  def config do
    [
      base_class: "button",
      type: :buttons,
      since: "0.6.0",
      maturity: :developing,
      extra: [disabled_class: "is-disabled"],
      modifiers: [
        variant: [
          values: [
            "primary",
            "secondary",
            "info",
            "success",
            "warning",
            "danger"
          ],
          default: "primary"
        ],
        size: [
          values: ["small", "normal", "medium", "large"],
          default: "normal"
        ],
        fill: [values: ["solid", "outline", "text"], default: "solid"],
        shape: [values: [nil, "circle", "pill"], default: nil]
      ]
    ]
  end

  @impl true
  def attrs_and_slots do
    quote do
      attr :disabled, :boolean,
        default: false,
        doc: """
        Since `<a>` tags cannot have a `disabled` attribute, this attribute
        toggles a class.
        """

      attr :rest, :global,
        include: [
          # HTML attributes
          "download",
          "hreflang",
          "referrerpolicy",
          "rel",
          "target",
          "type",
          # Phoenix.LiveView.Component.link/1 attributes
          "navigate",
          "patch",
          "href",
          "replace",
          "method",
          "csrf_token"
        ]

      slot :inner_block, required: true
    end
  end

  @impl true
  def init_block(_opts, extra) do
    disabled_class = Keyword.fetch!(extra, :disabled_class)

    quote do
      var!(assigns) =
        if var!(assigns)[:disabled] do
          Map.update!(
            var!(assigns),
            :class,
            &(&1 ++ [unquote(disabled_class)])
          )
        else
          var!(assigns)
        end
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.link class={@class} {@rest}>
      <%= render_slot(@inner_block) %>
    </.link>
    """
  end
end
