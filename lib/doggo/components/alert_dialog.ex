defmodule Doggo.Components.AlertDialog do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  alias Phoenix.LiveView.JS

  @impl true
  def doc do
    """
    Renders an alert dialog that requires the immediate attention and response
    of the user.

    This component is meant for situations where critical information must be
    conveyed, and an explicit response is required from the user. It is
    typically used for confirmation dialogs, warning messages, error
    notifications, and other scenarios where an immediate decision is necessary.

    For non-critical dialogs, such as those containing forms or additional
    information, use `Doggo.Components.build_modal/1` instead.
    """
  end

  @impl true
  def usage(%{name: name}) do
    """
    ```heex
    <.#{name} id="end-session-modal">
      <:title>End Training Session Early?</:title>
      <p>
        Are you sure you want to end the current training session with Bella?
        She's making great progress today!
      </p>
      <:footer>
        <.button phx-click="end-session">
          Yes, end session
        </.button>
        <.button phx-click={Doggo.JS.hide_modal("end-session-modal")}>
          No, continue training
        </.button>
      </:footer>
    </.#{name}>
    ```

    To open the dialog, use the `Doggo.JS.show_modal/1` function.

    ```heex
    <.button
      phx-click={Doggo.JS.show_modal("end-session-modal")}
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

    - using `Doggo.JS.hide_modal/1`,
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
        phx-click={Doggo.JS.hide_modal("end-session-modal")}
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
  def builder_doc do
    """
    - `:close_label` - The accessible name of the close button, and its text
      when `:close` is not set. Defaults to `"Close"`. An expression, such as
      `gettext("Close")` or a call to any other function, is evaluated at render
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
      type: :dialog,
      since: "0.6.0",
      maturity: :developing,
      extra: [close_label: "Close", close: nil],
      render_options: [close_label: :string, close: :content],
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
        A `Phoenix.LiveView.JS` command or event name to run when the dialog
        closes, for example to patch back to the URL the dialog was opened from.
        This attribute is not required to close the dialog.
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

      slot :title, required: true
      slot :inner_block, required: true, doc: "The modal body."

      slot :footer

      attr :rest, :global, doc: "Any additional HTML attributes."
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
      <dialog
        id={@id}
        role="alertdialog"
        class={[Doggo.build(:base_class) | List.wrap(@class)]}
        aria-labelledby={"#{@id}-title"}
        aria-describedby={"#{@id}-content"}
        closedby={@closedby}
        phx-hook="Doggo.Dialog"
        phx-mounted={Doggo.JS.dialog_mounted(@id, @open)}
        phx-remove={Doggo.JS.hide_modal(@id)}
        data-cancel={Doggo.JS.to_js!(@on_cancel, :on_cancel, ".alert_dialog")}
        {@data_attrs}
        {@rest}
      >
        <section>
          <header>
            <h2 id={"#{@id}-title"}>{render_slot(@title)}</h2>
            <button
              :if={@closedby != "none"}
              type="button"
              class={Doggo.build(:base_class, "-close")}
              aria-label={Doggo.build(:close_label)}
              command="close"
              commandfor={@id}
            >
              <Doggo.control_content
                content={Doggo.build(:close)}
                modifiers={@data_attrs.data}
                label={Doggo.build(:close_label)}
              />
            </button>
          </header>
          <div id={"#{@id}-content"} class={Doggo.build(:base_class, "-content")}>
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
end
