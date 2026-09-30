defmodule Doggo.Components.ButtonLink do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    Renders a link (`<a>`) that has the style of a button.

    Use this component when you need to style a link to a different page or a
    specific section within the same page as a button.

    To perform an action on the same page, including toggles and
    revealing/hiding elements, you should always use a real button instead. See
    `button/1`, `toggle_button/1`, and `disclosure_button/1`.
    """
  end

  @impl true
  def usage(%{name: name}) do
    """
    ```heex
    <.#{name} patch={~p"/confirm"}>
      Confirm
    </.#{name}>

    <.#{name} navigate={~p"/registration"}>
      Registration
    </.#{name}>
    ```
    """
  end

  @impl true
  def css_path do
    "components/button.css"
  end

  @impl true
  def config do
    [
      base_class: "button",
      type: :buttons,
      since: "0.6.0",
      maturity: :stable,
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
  def nested_classes(_) do
    []
  end

  @impl true
  def attrs_and_slots(_opts) do
    quote do
      attr :disabled, :boolean,
        default: false,
        doc: """
        Marks the link as unavailable.

        Since `<a>` tags cannot have a `disabled` attribute, the link is
        rendered without a destination, with `role="link"` and
        `aria-disabled="true"`. It stays in the tab order, so that the state can
        be discovered, but neither a click nor Enter activates it. Any `href`,
        `navigate` or `patch` you pass is ignored.

        Style it with the `[aria-disabled]` selector.
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
        ],
        doc: "Any additional HTML attributes."

      slot :inner_block, required: true
    end
  end

  @impl true
  def template(_opts) do
    quote do
      case var!(assigns) do
        %{disabled: true} ->
          # `Phoenix.Component.link/1` falls back to `href="#"` when no
          # destination is given. Use <a> directly, so that the link cannot be
          # activated. `role="link"` restores the semantics of <a> without
          # `href`.
          var!(assigns) =
            Phoenix.Component.update(
              var!(assigns),
              :rest,
              &Map.drop(&1, ~w(href navigate patch replace method csrf_token)a)
            )

          ~H"""
          <a
            class={[Doggo.build(:base_class) | List.wrap(@class)]}
            role="link"
            aria-disabled="true"
            tabindex="0"
            {@data_attrs}
            {@rest}
          >
            {render_slot(@inner_block)}
          </a>
          """

        _ ->
          ~H"""
          <.link
            class={[Doggo.build(:base_class) | List.wrap(@class)]}
            {@data_attrs}
            {@rest}
          >
            {render_slot(@inner_block)}
          </.link>
          """
      end
    end
  end
end
