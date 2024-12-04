defmodule Doggo.Components.Modal do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

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
    There are two primary ways to manage the display of the modal: via URL state
    or by setting and removing the `open` attribute.

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

    ### Without URL

    To toggle the modal visibility dynamically with the `open` attribute:

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

    To open modal, use the `show_modal/1` function.

    ```heex
    <.button
      phx-click={Doggo.show_modal("pet-modal")}
      aria-haspopup="dialog"
    >
      show
    </.button>
    ```

    ## CSS

    To hide the modal when the `open` attribute is not set, use the following CSS
    styles:

    ```css
    dialog.modal:not([open]),
    dialog.modal[open="false"] {
      display: none;
    }
    ```

    ## Semantics

    While the `showModal()` JavaScript function is typically recommended for
    managing modal dialog semantics, this component utilizes the `open` attribute
    to control visibility. This approach is chosen to eliminate the need for
    library consumers to add additional JavaScript code. To ensure proper
    modal semantics, the `aria-modal` attribute is added to the dialog element.
    """
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

      attr :on_cancel, Phoenix.LiveView.JS,
        default: %Phoenix.LiveView.JS{},
        doc: """
        An additional `Phoenix.LiveView.JS` command to execute when the dialog
        is canceled. This command is executed in addition to closing the dialog. If
        you only want the dialog to be closed, you don't have to set this attribute.
        """

      attr :dismissable, :boolean,
        default: true,
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
      class={@class}
      aria-modal={(@open && "true") || "false"}
      aria-labelledby={"#{@id}-title"}
      open={@open}
      phx-mounted={@open && Doggo.show_modal(@id)}
      phx-remove={Doggo.hide_modal(@id)}
      data-cancel={Phoenix.LiveView.JS.exec(@on_cancel, "phx-remove")}
      {@rest}
    >
      <.focus_wrap
        id={"#{@id}-container"}
        class={"#{@base_class}-container"}
        phx-window-keydown={
          @dismissable && Phoenix.LiveView.JS.exec("data-cancel", to: "##{@id}")
        }
        phx-key={@dismissable && "escape"}
        phx-click-away={
          @dismissable && Phoenix.LiveView.JS.exec("data-cancel", to: "##{@id}")
        }
      >
        <section>
          <header>
            <button
              :if={@dismissable}
              href="#"
              class={"#{@base_class}-close"}
              aria-label={@close_label}
              phx-click={Phoenix.LiveView.JS.exec("data-cancel", to: "##{@id}")}
            >
              {render_slot(@close)}
              <span :if={@close == []}>close</span>
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
