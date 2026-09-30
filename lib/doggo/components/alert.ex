defmodule Doggo.Components.Alert do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    The alert component serves as a notification mechanism to provide feedback
    to the user.

    For supplementary information that doesn't require the user's immediate
    attention, use `callout/1` instead.
    """
  end

  @impl true
  def usage do
    """
    Minimal example:

    ```heex
    <.alert id="some-alert"></.alert>
    ```

    With title, icon and level:

    ```heex
    <.alert id="some-alert" level={:info}>
      <:title>Info</:title>
      message
      <:icon><Heroicon.light_bulb /></:icon>
    </.alert>
    ```

    Dismissable:

    ```heex
    <.alert id="some-alert" on_close={JS.push("dismiss")}>
      message
    </.alert>
    ```

    The close button's name and content are set in the build call:

    ```elixir
    build_alert(close_label: gettext("Dismiss"), close: ~H|<Heroicon.x_mark />|)
    ```

    With an action:

    ```heex
    <.alert id="some-alert">
      <:title>Session expired</:title>
      Your session has expired. Sign in again to continue.
      <:action>
        <.button phx-click="sign-in">Sign in</.button>
      </:action>
    </.alert>
    ```

    The `close_label` is the button's accessible name, so it is needed whether
    or not `close` is set.
    """
  end

  @impl true
  def css_path do
    "components/alert.css"
  end

  @impl true
  def builder_doc do
    """
    - `:close_label` - The accessible name of the close button, and its text
      when `:close` is not set. Defaults to `"Close"`. An expression, such as
      `gettext("Close")` or any other function call, is evaluated at render
      time.
    - `:close` - The content of the close button: a remote capture of a
      function component or inline HEEx, such as `~H|<.icon name="x" />|`. It
      renders with the values of the modifiers as assigns. Defaults to `nil`,
      which renders `close_label` as text.
    """
  end

  @impl true
  def config do
    [
      type: :feedback,
      since: "0.6.0",
      maturity: :developing,
      extra: [close_label: "Close", close: nil],
      render_options: [close_label: :string, close: :content],
      modifiers: [
        level: [
          values: [
            "info",
            "success",
            "warning",
            "danger"
          ],
          default: "info"
        ]
      ]
    ]
  end

  @impl true
  def own_attributes, do: ["aria-labelledby": nil, role: nil]

  @impl true
  def nested_classes(base_class) do
    [
      "#{base_class}-icon",
      "#{base_class}-body",
      "#{base_class}-title",
      "#{base_class}-message",
      "#{base_class}-actions",
      "#{base_class}-close"
    ]
  end

  @impl true
  def attrs_and_slots(_opts) do
    quote do
      attr :id, :string, required: true

      attr :on_close, :any,
        default: nil,
        doc: """
        `Phoenix.LiveView.JS` command or event name to run when the close button
        is clicked. If not set, no close button is rendered.
        """

      attr :rest, :global, doc: "Any additional HTML attributes."

      slot :title, doc: "An optional title."
      slot :inner_block, required: true, doc: "The main content of the alert."
      slot :icon, doc: "Optional slot to render an icon."

      slot :action,
        doc: """
        A slot for action buttons related to the alert, rendered after the
        message.
        """
    end
  end

  @impl true
  def template(opts) do
    name = ".#{Keyword.fetch!(opts, :name)}"

    quote do
      Doggo.diagnostic do
        Doggo.ensure_name!(
          Doggo.build(:close_label),
          unquote(name),
          "close_label"
        )
      end

      ~H"""
      <div
        id={@id}
        role="alert"
        aria-labelledby={@title != [] && "#{@id}-title"}
        class={[Doggo.build(:base_class) | List.wrap(@class)]}
        {@data_attrs}
        {@rest}
      >
        <div :if={@icon != []} class={Doggo.build(:base_class, "-icon")}>
          {render_slot(@icon)}
        </div>
        <div class={Doggo.build(:base_class, "-body")}>
          <div
            :if={@title != []}
            id={"#{@id}-title"}
            class={Doggo.build(:base_class, "-title")}
          >
            {render_slot(@title)}
          </div>
          <div
            class={Doggo.build(:base_class, "-message")}
            phx-no-format
          >{render_slot(@inner_block)}</div>
          <div :if={@action != []} class={Doggo.build(:base_class, "-actions")}>
            <%= for action <- @action do %>
              {render_slot(action)}
            <% end %>
          </div>
        </div>
        <button
          :if={@on_close}
          type="button"
          class={Doggo.build(:base_class, "-close")}
          aria-label={Doggo.build(:close_label)}
          phx-click={Doggo.callback!(@on_close, :on_close, ".alert")}
        >
          <Doggo.control_content
            content={Doggo.build(:close)}
            modifiers={@data_attrs.data}
            label={Doggo.build(:close_label)}
          />
        </button>
      </div>
      """
    end
  end
end
