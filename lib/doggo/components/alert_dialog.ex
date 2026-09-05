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
      phx-click={Doggo.show_modal("end-session-modal")}
      aria-haspopup="dialog"
    >
      show
    </.button>
    ```

    ### With HTML attributes

    `command` and `commandfor` are the Invoker Commands API. Unlike the other
    two ways, this API needs no JavaScript at all.

    ```heex
    <.button command="show-modal" commandfor="end-session-modal">show</.button>
    ```

    Both attributes are recent, so the hook handles them if the browser doesn't
    support them.

    ### Closing

    The alert dialog can be closed by:

    - using `hide_modal/1`,
    - using `JS.exec("data-cancel", to: "#end-session-modal")`, which is what
      the example above uses for its own control, or
    - using the close button or `Esc` (only if `dismissable` is set).

    ## Semantics

    The dialog is opened with `showModal()`, so the browser puts it in the top
    layer, draws `::backdrop`, makes the rest of the document inert and keeps
    the focus inside. `aria-modal` is not rendered, because `showModal()`
    already marks the component as a modal.

    ## CSS

    A dialog is hidden until it is opened, so no rule is needed for that. Style
    the backdrop with `dialog.alert-dialog::backdrop`.

    ## Caveats

    An alert dialog is not dismissable by default, so it renders
    `closedby="none"` and no close button, which leaves no way to dismiss it
    from the component. Provide your own control in the `:footer` slot.
    """
  end

  @impl true
  def keyboard do
    """
    - `Esc` - close the dialog (only if `dismissable` is set).
    """
  end

  @impl true
  def css_path do
    "components/_dialog.scss"
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
        When set to `true`, the dialog renders a close button and
        `closedby="any"`, so that it can also be dismissed with the escape key
        or by clicking outside it.
        """

      attr :close_label, :string,
        default: "Close",
        doc: """
        Aria label for the close button. This value should be translated to the
        language in which the rest of the page is displayed.
        """

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
      aria-labelledby={"#{@id}-title"}
      aria-describedby={"#{@id}-content"}
      closedby={(@dismissable && "any") || "none"}
      phx-hook="Doggo.Dialog"
      phx-mounted={Doggo.dialog_mounted(@id, @open)}
      phx-remove={Doggo.hide_modal(@id)}
      data-cancel={JS.exec(@on_cancel, "phx-remove")}
      {@data_attrs}
      {@rest}
    >
      <div id={"#{@id}-container"} class={"#{@base_class}-container"}>
        <section>
          <header>
            <button
              :if={@dismissable}
              type="button"
              class={"#{@base_class}-close"}
              aria-label={@close_label}
              command="close"
              commandfor={@id}
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
      </div>
    </dialog>
    """
  end
end
