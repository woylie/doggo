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
        <.link phx-click={Doggo.hide_modal("pet-modal")}>
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
        <.link phx-click={Doggo.hide_modal("pet-modal")}>
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

    These close the dialog, and all of them run `on_cancel`:

    - the close button the component renders, which uses `command="close"`,
      and `Esc`, unless `closedby` is `"none"`
    - a click outside, if `closedby` is `"any"`
    - `hide_modal/1`

    ## Semantics

    The dialog is opened with `showModal()`, so the browser puts it in the top
    layer, draws `::backdrop`, makes the rest of the document inert and keeps
    the focus inside. `aria-modal` is not rendered, because `showModal()`
    already marks the component as a modal.


    ## Focus

    `showModal()` moves the focus into the dialog to the first element with the
    `autofocus` attribute, or the first focusable element if no element has it.

    Unless `closedby` is `"none"`, the close button comes first in the markup,
    so it receives the focus if no `autofocus` attribute is present. This is
    rarely desired.

    Set `autofocus` on the element that should receive the focus:

    ```heex
    <.modal id="edit-dog">
      <:title>Edit dog</:title>
      <form>
        <input type="text" name="name" autofocus />
      </form>
    </.modal>
    ```

    The most appropriate element to focus depends on the dialog:

    - If the reader has to work through the content, focus a static element at
      the top. Opening a modal announces its title and the focused element, but
      not the body. If a control is focused, the content remains unread until
      the reader starts looking for it. Focusing a control also scrolls it into
      view, which can push the beginning of a long body out of sight.
    - If the dialog has focusable elements in the body, such as a form, set the
      focus to the first such element (e.g. the first input).
    - If the dialog only informs or continues a process, set the focus to the
      `OK` or `Continue` button.
    - If the dialog completes a step that is not easily reversible, set the
      focus to the least destructive action.

    To focus a static element, set both `tabindex="-1"` and `autofocus`:

    ```heex
    <.modal id="terms">
      <:title>Terms of service</:title>
      <p tabindex="-1" autofocus>Read the following before continuing.</p>
      <h3>Eligibility</h3>
      ...
    </.modal>
    ```

    If the body is short, it can be announced when the modal opens instead by
    setting `aria-describedby` to the id of the content element (modal id plus
    `-content` suffix):

    ```heex
    <.modal id="delete-dog" aria-describedby="delete-dog-content">
      <:title>Delete Bella?</:title>
      <p>This cannot be undone.</p>
    </.modal>
    ```

    A description is announced as a single run of text. Don't set
    `aria-describedby` if the content has a structure to navigate, such as a
    form, a table, or multiple paragraphs.

    See also [ARIA Authoring Practices](https://www.w3.org/WAI/ARIA/apg/patterns/dialog-modal/).

    ## CSS

    A dialog is hidden until it is opened, so no rule is needed for that. Style
    the backdrop with `dialog.modal::backdrop`.

    ## Caveats

    Setting `closedby="none"` removes the close button, which leaves no way to
    dismiss the dialog from the component. Provide your own control in the
    `:footer` slot when you do that.
    """
  end

  @impl true
  def keyboard do
    """
    - `Esc` - close the dialog, unless `closedby` is `"none"`.

    Opening the dialog moves the focus to the first focusable element inside it,
    and closing it returns the focus to the element that opened it. The focus
    stays within the dialog while it is open. A dialog with nothing focusable in
    it leaves the focus outside.
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
  def own_attributes, do: ["aria-labelledby": nil, "phx-hook": nil]

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
        doc: "Initializes the modal as open."

      attr :on_cancel, :any,
        default: %JS{},
        doc: """
        A `Phoenix.LiveView.JS` command or event name to run when the dialog
        closes, for example to patch back to the URL the dialog was opened from.
        This attribute is not required to close the dialog.
        """

      attr :closedby, :string,
        values: ["any", "closerequest", "none"],
        default: "any",
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
        class={[Doggo.build(:base_class) | List.wrap(@class)]}
        aria-labelledby={"#{@id}-title"}
        closedby={@closedby}
        phx-hook="Doggo.Dialog"
        phx-mounted={Doggo.dialog_mounted(@id, @open)}
        phx-remove={Doggo.hide_modal(@id)}
        data-cancel={Doggo.to_js!(@on_cancel, :on_cancel, ".modal")}
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
