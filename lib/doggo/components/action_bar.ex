defmodule Doggo.Components.ActionBar do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    The action bar offers users quick access to primary actions within the
    application.

    It is typically positioned to float above other content.
    """
  end

  @impl true
  def usage do
    """
    ```heex
    <.action_bar id="dog-actions" label="Dog actions">
      <:item label="Edit" on_click={JS.push("edit")}>
        <.icon><Lucideicons.pencil aria-hidden /></.icon>
      </:item>
      <:item label="Move" on_click={JS.push("move")}>
        <.icon><Lucideicons.move aria-hidden /></.icon>
      </:item>
      <:item label="Archive" on_click={JS.push("archive")}>
        <.icon><Lucideicons.archive aria-hidden /></.icon>
      </:item>
    </.action_bar>
    ```

    This component needs the `Doggo.Toolbar` JavaScript hook. See
    [Phoenix LiveView Hooks](readme.html#phoenix-liveview-hooks) for
    registering it.
    """
  end

  @impl true
  def keyboard do
    """
    - `Left` and `Right` - move between the buttons, wrapping at the ends.
    - `Home` and `End` - first and last button.
    - `Enter` or `Space` - run the focused button's `on_click`.

    The action bar is a single tab stop. `Tab` moves to the button the user last
    used, and the arrow keys move between them.
    """
  end

  @impl true
  def css_path do
    "components/toolbar.css"
  end

  @impl true
  def config do
    [
      type: :buttons,
      since: "0.6.0",
      maturity: :developing,
      modifiers: []
    ]
  end

  @impl true
  def own_attributes, do: ["aria-label": :label, "phx-hook": nil, role: nil]

  @impl true
  def nested_classes(base_class) do
    ["#{base_class}-item"]
  end

  @impl true
  def attrs_and_slots(_opts) do
    quote do
      attr :id, :string,
        required: true,
        doc: "A unique DOM ID. Required for the JavaScript hook."

      attr :label, :string,
        default: nil,
        doc: """
        The accessible name of the action bar, rendered as `aria-label`. It
        says what the actions apply to, for example "Dog actions".

        Set either `label` or `labelledby`.

        Do not repeat the word `toolbar` in the label. Screen readers announce
        the role along with the name. Using the role in the label would make
        screen readers repeat it.
        """

      attr :labelledby, :string,
        default: nil,
        doc: """
        The DOM ID of an element that labels the action bar.

        Set either `label` or `labelledby`.
        """

      attr :rest, :global, doc: "Any additional HTML attributes."

      slot :item,
        required: true,
        doc: """
        An action. The content can be an icon, an icon with text, or text.

        `label` is the button's accessible name. It is rendered as `aria-label`
        and as `title`, so that an icon-only item is named and has a hover
        tooltip.

        If the content includes visible text, `label` must contain that text,
        since `aria-label` overrides the content. Voice control users activate a
        button by speaking the name they can see, so a button reading "Delete"
        with `label="Remove record"` cannot be activated by voice.
        """ do
        attr :label, :string, required: true

        attr :on_click, :any,
          required: true,
          doc: "`Phoenix.LiveView.JS` command or event name."
      end
    end
  end

  @impl true
  def init_block(opts, _extra) do
    name = ".#{Keyword.fetch!(opts, :name)}"

    quote do
      require Doggo

      Doggo.diagnostic do
        for entry <- var!(assigns).item do
          Doggo.ensure_name!(entry[:label], unquote(name), "label")
        end
      end
    end
  end

  @impl true
  def example_label, do: "Dog actions"

  @impl true
  def render(%{item: []} = assigns), do: ~H""

  def render(assigns) do
    ~H"""
    <div
      id={@id}
      role="toolbar"
      class={@class}
      aria-label={@label}
      aria-labelledby={@labelledby}
      phx-hook="Doggo.Toolbar"
      {@data_attrs}
      {@rest}
    >
      <button
        :for={item <- @item}
        type="button"
        class={"#{@base_class}-item"}
        phx-click={Doggo.callback!(item.on_click, :on_click, ".action_bar")}
        aria-label={item.label}
        title={item.label}
      >
        {render_slot(item)}
      </button>
    </div>
    """
  end
end
