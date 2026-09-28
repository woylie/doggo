defmodule Doggo.Components.Toggletip do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    Renders a button that reveals supplementary information when it is pressed.

    A toggletip explains the thing next to it, such as a label or a heading.
    Unlike a tooltip, which describes a control that has a purpose of its own,
    the button of a toggletip exists only to show the information. The panel
    opens on activation, stays open until it is dismissed, and may hold links.
    """
  end

  @impl true
  def usage do
    """
    With an icon, the label names the button for screen readers:

    ```heex
    <.toggletip id="adoption-fee-info" label="About the adoption fee">
      <:icon><.icon name="info" /></:icon>
      The fee covers vaccinations, a microchip and the first vet visit.
      <a href="/adoption/fees">How fees are used</a>
    </.toggletip>
    ```

    Without an icon, the label is the button's visible text.

    A toggletip holds supplementary information only. Information a user needs
    to complete a task, such as the rules for a password, belongs in visible
    text, for example the field's description. Place the toggletip beside the
    element it explains, never inside a `<label>`, a button, a link or a
    `<summary>`. Inside a label, the button's name becomes part of the name of
    the input the label belongs to.

    The panel is the browser's popover. It opens and closes without JavaScript,
    closes on `Esc` and on a click outside, and opening one toggletip closes the
    others. The `Doggo.Toggletip` JavaScript hook announces the panel's text
    when it opens. See
    [Phoenix LiveView Hooks](readme.html#phoenix-liveview-hooks) for
    registering it.
    """
  end

  @impl true
  def keyboard do
    """
    - `Enter`, `Space` - open or close the panel.
    - `Tab` - move from the button into the panel's links, if it has any.
    - `Esc` - close the panel.
    """
  end

  @impl true
  def css_path do
    "components/toggletip.css"
  end

  @impl true
  def config do
    [
      type: :feedback,
      since: "0.17.0",
      maturity: :experimental,
      modifiers: []
    ]
  end

  @impl true
  def example_label, do: "About the adoption fee"

  @impl true
  def nested_classes(base_class) do
    [
      "#{base_class}-button",
      "#{base_class}-icon",
      "#{base_class}-label",
      "#{base_class}-panel",
      "#{base_class}-status"
    ]
  end

  @impl true
  def attrs_and_slots(_opts) do
    quote do
      attr :id, :string, required: true

      attr :label, :string,
        default: nil,
        doc: """
        The name of the button. It should state what the information is about,
        for example "About the adoption fee", so that several toggletips on a
        page can be told apart. With the `:icon` slot, the label is visually
        hidden.

        Set either `label` or `labelledby`.
        """

      attr :labelledby, :string,
        default: nil,
        doc: """
        The DOM ID of an element that labels the button. If set, the button only
        shows the icon and the `:icon` slot must be set as well.
        """

      attr :rest, :global, doc: "Any additional HTML attributes."

      slot :inner_block,
        required: true,
        doc: "The supplementary information. It may hold links."

      slot :icon,
        doc: """
        An icon for the button. It is hidden from the accessibility tree, since
        the label names the button.
        """
    end
  end

  @impl true
  def init_block(_opts, _extra) do
    []
  end

  @impl true
  def template(_opts) do
    quote do
      Doggo.diagnostic do
        unquote(__MODULE__).ensure_icon!(var!(assigns))
      end

      ~H"""
      <div
        id={@id}
        class={[Doggo.build(:base_class) | List.wrap(@class)]}
        phx-hook="Doggo.Toggletip"
        {@data_attrs}
        {@rest}
      >
        <button
          type="button"
          class={Doggo.build(:base_class, "-button")}
          popovertarget={"#{@id}-panel"}
          aria-labelledby={@labelledby}
        >
          <span
            :if={@icon != []}
            class={Doggo.build(:base_class, "-icon")}
            aria-hidden="true"
          >
            {render_slot(@icon)}
          </span>
          <span
            :if={@label}
            class={Doggo.build(:base_class, "-label")}
            data-visually-hidden={@icon != []}
          >
            {@label}
          </span>
        </button>
        <div
          id={"#{@id}-panel"}
          class={Doggo.build(:base_class, "-panel")}
          popover="auto"
        >
          {render_slot(@inner_block)}
        </div>
        <span
          class={Doggo.build(:base_class, "-status")}
          role="status"
          data-visually-hidden
        ></span>
      </div>
      """
    end
  end

  @doc false
  def ensure_icon!(%{labelledby: labelledby, icon: []})
      when labelledby != nil do
    raise ArgumentError, """
    missing icon for toggletip

    A toggletip labelled with labelledby renders no button text and requires the
    icon slot:

        <.toggletip id="fee-info" labelledby="fee-heading">
          <:icon><.icon name="info" /></:icon>
          The fee covers vaccinations.
        </.toggletip>
    """
  end

  def ensure_icon!(_assigns), do: :ok
end
