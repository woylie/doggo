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
        <.button phx-click={Doggo.hide_modal("end-session-modal")}>
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
    - using the close button or `Esc`, unless `closedby` is `"none"`, or
    - clicking outside it, if `closedby` is `"any"`.

    Each of them runs `on_cancel` once.

    ## Semantics

    The dialog is opened with `showModal()`, so the browser puts it in the top
    layer, draws `::backdrop`, makes the rest of the document inert and keeps
    the focus inside. `aria-modal` is not rendered, because `showModal()`
    already marks the component as a modal.

    ## Focus

    `showModal()` moves the focus into the dialog to the first element with the
    `autofocus` attribute, or the first focusable element if no element has it.

    An alert dialog renders no close button by default, so the first focusable
    element is usually the first control in the `:footer` slot. With a close
    button, it is the close button. Neither is likely to be the right element
    to focus.

    Set `autofocus` on the element that should receive the focus:

    ```heex
    <:footer>
      <.button phx-click="end-session">Yes, end session</.button>
      <.button
        autofocus
        phx-click={Doggo.hide_modal("end-session-modal")}
      >
        No, continue training
      </.button>
    </:footer>
    ```

    In an alert dialog, the focus should move to the least destructive action,
    as recommended in the
    [ARIA Authoring Practices](https://www.w3.org/WAI/ARIA/apg/patterns/alertdialog/).

    ## CSS

    A dialog is hidden until it is opened, so no rule is needed for that. Style
    the backdrop with `dialog.alert-dialog::backdrop`.

    ## Caveats

    An alert dialog defaults to `closedby="none"`, which means that it does not
    render a close button. Provide your own control in the `:footer` slot.
    """
  end

  @impl true
  def keyboard do
    """
    - `Esc` - close the dialog, unless `closedby` is `"none"`.
    """
  end

  @impl true
  def css_path do
    "components/dialog.css"
  end

  @impl true
  def config do
    [
      type: :dialog,
      since: "0.6.0",
      maturity: :developing,
      modifiers: []
    ]
  end

  @impl true
  def own_attributes do
    [
      "aria-describedby": nil,
      "aria-labelledby": nil,
      "phx-hook": nil,
      role: nil
    ]
  end

  @impl true
  def nested_classes(base_class) do
    [
      "#{base_class}-close",
      "#{base_class}-content"
    ]
  end

  @impl true
  def attrs_and_slots(_opts) do
    quote do
      attr :id, :string, required: true

      attr :open, :boolean,
        default: false,
        doc: "Initializes the dialog as open."

      attr :on_cancel, :any,
        default: %JS{},
        doc: """
        An additional `Phoenix.LiveView.JS` command or event name to execute
        when the dialog is canceled. This command is executed in addition to closing the dialog. If
        you only want the dialog to be closed, you don't have to set this attribute.
        """

      attr :closedby, :string,
        values: ["any", "closerequest", "none"],
        default: "none",
        doc: """
        How the user can close the dialog. The value is rendered as the
        dialog's `closedby` attribute.

        - `"any"` - the close button, `Esc` and a click outside.
        - `"closerequest"` - the close button and `Esc`, but not a click
          outside. Use it for a form that should not lose its input to a stray
          click.
        - `"none"` - no close button is rendered and neither `Esc` nor a click
          outside can close the dialog. You need to provide your own control.
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
  def init_block(opts, _extra) do
    name = ".#{Keyword.fetch!(opts, :name)}"

    quote do
      require Doggo

      Doggo.diagnostic do
        Doggo.ensure_name!(
          var!(assigns).close_label,
          unquote(name),
          "close_label"
        )
      end
    end
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
      closedby={@closedby}
      phx-hook="Doggo.Dialog"
      phx-mounted={Doggo.dialog_mounted(@id, @open)}
      phx-remove={Doggo.hide_modal(@id)}
      data-cancel={Doggo.to_js!(@on_cancel, :on_cancel, ".alert_dialog")}
      {@data_attrs}
      {@rest}
    >
      <section>
        <header>
          <h2 id={"#{@id}-title"}>{render_slot(@title)}</h2>
          <button
            :if={@closedby != "none"}
            type="button"
            class={"#{@base_class}-close"}
            aria-label={@close_label}
            command="close"
            commandfor={@id}
          >
            {render_slot(@close)}
            <span :if={@close == []}>{@close_label}</span>
          </button>
        </header>
        <div id={"#{@id}-content"} class={"#{@base_class}-content"}>
          {render_slot(@inner_block)}
        </div>
        <footer :if={@footer != []}>
          {render_slot(@footer)}
        </footer>
      </section>
    </dialog>
    """
  end
end
