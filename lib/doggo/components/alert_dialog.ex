defmodule Doggo.Components.AlertDialog do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  alias Phoenix.LiveView.JS

  @impl true
  def doc do
    """
    Renders an alert dialog that requires the immediate attention and response of
    the user.

    This component is meant for situations where critical information must be
    conveyed, and an explicit response is required from the user. It is typically
    used for confirmation dialogs, warning messages, error notifications, and
    other scenarios where an immediate decision is necessary.

    For non-critical dialogs, such as those containing forms or additional
    information, use `Doggo.Components.build_modal/1` instead.
    """
  end

  @impl true
  def usage do
    """
    ```heex
    <.alert_dialog id="end-session-modal">
      <:title>End Training Session Early?</:title>
      <p>
        Are you sure you want to end the current training session with Bella?
        She's making great progress today!
      </p>
      <:footer>
        <.button phx-click="end-session">
          Yes, end session
        </.button>
        <.button phx-click={JS.exec("data-cancel", to: "#end-session-modal")}>
          No, continue training
        </.button>
      </:footer>
    </.alert_dialog>
    ```

    To open the dialog, use the `show_modal/1` function.

    ```heex
    <.button
      phx-click={.show_modal("end-session-modal")}
      aria-haspopup="dialog"
    >
      show
    </.button>
    ```

    ## CSS

    To hide the modal when the `open` attribute is not set, use the following CSS
    styles:

    ```css
    dialog.alert-dialog:not([open]),
    dialog.alert-dialog[open="false"] {
      display: none;
    }
    ```

    ## Semantics

    While the `showModal()` JavaScript function is typically recommended for
    managing modal dialog semantics, this component utilizes the `open` attribute
    to control visibility. This approach is chosen to eliminate the need for
    library consumers to add additional JavaScript code. To ensure proper
    modal semantics, the `aria-modal` attribute is added to the dialog element.

    ## Caveats

    Because the dialog is opened with the `open` attribute rather than
    `showModal()`, it is not a modal dialog in the browser's sense, whatever
    `aria-modal` reports. It is not placed in the top layer, `::backdrop` does
    not apply, and content behind it stays interactive and scrollable. You need
    to supply your own backdrop and lock scrolling on the body yourself.

    Setting `dismissable={false}` removes the close button and the Escape and
    click-away handlers, which leaves no way to dismiss the dialog from the
    component. Provide your own control in the `:footer` slot when you do that.
    """
  end

  @impl true
  def config do
    [
      type: :feedback,
      since: "0.6.0",
      maturity: :developing,
      modifiers: []
    ]
  end

  @impl true
  def nested_classes(base_class) do
    [
      "#{base_class}-close",
      "#{base_class}-container",
      "#{base_class}-content"
    ]
  end

  @impl true
  def attrs_and_slots do
    quote do
      attr :id, :string, required: true

      attr :open, :boolean,
        default: false,
        doc: "Initializes the dialog as open."

      attr :on_cancel, JS,
        default: %JS{},
        doc: """
        An additional `Phoenix.LiveView.JS` command to execute when the dialog
        is canceled. This command is executed in addition to closing the dialog. If
        you only want the dialog to be closed, you don't have to set this attribute.
        """

      attr :dismissable, :boolean,
        default: false,
        doc: """
        When set to `true`, the dialog can be dismissed by clicking a close button
        or by pressing the escape key.
        """

      attr :close_label, :string,
        default: "Close",
        doc: "Aria label for the close button."

      slot :title, required: true
      slot :inner_block, required: true, doc: "The modal body."

      slot :close,
        doc: "The content for the 'close' link. Defaults to the word 'close'."

      slot :footer

      attr :rest, :global, doc: "Any additional HTML attributes."
    end
  end

  @impl true
  def init_block(_opts, _extra) do
    []
  end

  @impl true
  def render(assigns) do
    ~H"""
    <dialog
      id={@id}
      role="alertdialog"
      class={@class}
      aria-modal={(@open && "true") || "false"}
      aria-labelledby={"#{@id}-title"}
      aria-describedby={"#{@id}-content"}
      open={@open}
      phx-mounted={@open && Doggo.show_modal(@id)}
      phx-remove={Doggo.hide_modal(@id)}
      data-cancel={JS.exec(@on_cancel, "phx-remove")}
      {@data_attrs}
      {@rest}
    >
      <.focus_wrap
        id={"#{@id}-container"}
        class={"#{@base_class}-container"}
        tabindex="-1"
        phx-window-keydown={@dismissable && JS.exec("data-cancel", to: "##{@id}")}
        phx-key={@dismissable && "escape"}
        phx-click-away={@dismissable && JS.exec("data-cancel", to: "##{@id}")}
      >
        <section>
          <header>
            <button
              :if={@dismissable}
              type="button"
              class={"#{@base_class}-close"}
              aria-label={@close_label}
              phx-click={JS.exec("data-cancel", to: "##{@id}")}
            >
              {render_slot(@close)}
              <span :if={@close == []}>{@close_label}</span>
            </button>
            <h2 id={"#{@id}-title"}>{render_slot(@title)}</h2>
          </header>
          <div id={"#{@id}-content"} class={"#{@base_class}-content"}>
            {render_slot(@inner_block)}
          </div>
          <footer :if={@footer != []}>
            {render_slot(@footer)}
          </footer>
        </section>
      </.focus_wrap>
    </dialog>
    """
  end
end
