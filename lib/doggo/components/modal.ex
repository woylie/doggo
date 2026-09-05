defmodule Doggo.Components.Modal do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  alias Phoenix.LiveView.JS

  @impl true
  def doc do
    """
    Renders a modal dialog for content such as forms and informational panels.

    This component is appropriate for non-critical interactions. For dialogs
    requiring immediate user response, such as confirmations or warnings, use
    `.alert_dialog/1` instead.
    """
  end

  @impl true
  def usage do
    """
    The dialog is opened with `showModal()` in one of three ways: from the URL,
    with the `show_modal/1` and `hide_modal/1` functions, or with a button that
    uses the Invoker Commands API.

    ### With URL

    To toggle the modal visibility based on the URL:

    1. Use the `:if` attribute to conditionally render the modal when a specific
       live action matches.
    2. Set the `on_cancel` attribute to patch back to the original URL when the
       user chooses to close the modal.
    3. Set the `open` attribute to declare the modal's initial visibility state.

    #### Example

    ```heex
    <.modal
      :if={@live_action == :show}
      id="pet-modal"
      on_cancel={JS.patch(~p"/pets")}
      open
    >
      <:title>Show pet</:title>
      <p>My pet is called Johnny.</p>
      <:footer>
        <.link phx-click={JS.exec("data-cancel", to: "#pet-modal")}>
          Close
        </.link>
      </:footer>
    </.modal>
    ```

    To open the modal, patch or navigate to the URL associated with the live
    action.

    ```heex
    <.link patch={~p"/pets/\#{@id}"}>show</.link>
    ```

    ### With JS commands

    To toggle the modal visibility dynamically:

    1. Omit the `open` attribute in the template.
    2. Use the `show_modal/1` and `hide_modal/1` functions to change the
       visibility.

    #### Example

    ```heex
    <.modal id="pet-modal">
      <:title>Show pet</:title>
      <p>My pet is called Johnny.</p>
      <:footer>
        <.link phx-click={JS.exec("data-cancel", to: "#pet-modal")}>
          Close
        </.link>
      </:footer>
    </.modal>
    ```

    To open the modal, use the `show_modal/1` function.

    ```heex
    <.button
      phx-click={Doggo.show_modal("pet-modal")}
      aria-haspopup="dialog"
    >
      show
    </.button>
    ```

    ### With HTML attributes

    `command` and `commandfor` are the Invoker Commands API. Unlike the other
    two ways, this API needs no JavaScript at all.

    ```heex
    <.button command="show-modal" commandfor="pet-modal">show</.button>
    ```

    Both attributes are recent, so the hook handles them if the browser doesn't
    support them.

    ### Closing

    Four things close the dialog, and all of them run `on_cancel`:

    - the close button the component renders, which uses `command="close"`
    - `Esc` and a click outside, unless `dismissable` is set to `false`
    - `hide_modal/1`
    - `JS.exec("data-cancel", to: "#pet-modal")`

    ## Semantics

    The dialog is opened with `showModal()`, so the browser puts it in the top
    layer, draws `::backdrop`, makes the rest of the document inert and keeps
    the focus inside. `aria-modal` is not rendered, because `showModal()`
    already marks the component as a modal.

    ## CSS

    A dialog is hidden until it is opened, so no rule is needed for that. Style
    the backdrop with `dialog.modal::backdrop`.

    ## Caveats

    Setting `dismissable={false}` removes the close button and renders
    `closedby="none"`, which leaves no way to dismiss the dialog from the
    component. Provide your own control in the `:footer` slot when you do that.
    """
  end

  @impl true
  def keyboard do
    """
    - `Esc` - close the dialog, unless `dismissable` is set to `false`.

    Opening the dialog moves the focus to the first focusable element inside it,
    and closing it returns the focus to the element that opened it. The focus
    stays within the dialog while it is open. A dialog with nothing focusable in
    it leaves the focus outside.
    """
  end

  @impl true
  def css_path do
    "components/_dialog.scss"
  end

  @impl true
  def config do
    [
      type: :miscellaneous,
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
        doc: "Initializes the modal as open."

      attr :on_cancel, JS,
        default: %JS{},
        doc: """
        An additional `Phoenix.LiveView.JS` command to execute when the dialog
        is canceled. This command is executed in addition to closing the dialog. If
        you only want the dialog to be closed, you don't have to set this attribute.
        """

      attr :dismissable, :boolean,
        default: true,
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
      class={@class}
      aria-labelledby={"#{@id}-title"}
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
