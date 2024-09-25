defmodule Doggo.Components.TabNavigation do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    Renders navigation tabs.

    This component is meant for tabs that link to a different view or live
    action, each with a distinct URL. If you want to render tabs that switch
    between in-page content panels, use `tabs/1` instead.
    """
  end

  @impl true
  def usage do
    """
    ```heex
    <.tab_navigation current_value={@live_action}>
      <:item
        patch={~p"/pets/\#{@pet}"}
        value={[:show, :edit]}
      >
        Profile
      </:item>
      <:item
        patch={~p"/pets/\#{@pet}/appointments"}
        value={:appointments}
      >
        Appointments
      </:item>
      <:item
        patch={~p"/pets/\#{@pet}/messages"}
        value={:messages}
      >
        Messages
      </:item>
    </.tab_navigation>
    ```

    ### Current Item

    Each item has a `value` attribute that can be either a single value or a
    list of values. If you patch between live actions using this component, you
    would set the value to the list of live actions for which this tab is
    active.

    The root element itself has a `current_value` attribute. To determine
    whether a tab item is active, the current value is compared with the value
    of the tab item. If the value is a list, the tab item is considered active
    if the current value is contained in that list.

    Tab items are marked active by setting `aria-current="page"`. You can select
    the item in CSS with `.tab-navigation a[aria-current]`.
    """
  end

  @impl true
  def css_path do
    "components/_tab-navigation.scss"
  end

  @impl true
  def config do
    [
      type: :navigation,
      since: "0.6.0",
      maturity: :refining,
      modifiers: []
    ]
  end

  @impl true
  def nested_classes(_) do
    []
  end

  @impl true
  def attrs_and_slots do
    quote do
      attr :label, :string,
        default: "Tabs",
        doc: """
        Aria label for the `<nav>` element. The label is especially important if you
        have multiple `<nav>` elements on the same page, since it allows users
        to differentiate between different navigation sections.

        If the page is localized, ensure that the label is translated. Avoid
        using the word "navigation" in the label, since screen readers will
        already announce the "navigation" role. Additionally, the label should
        begin with a capital letter to ensure the correct inflection when read
        by screen readers.
        """

      attr :current_value, :any,
        required: true,
        doc: """
        The current value used to compare the item values with. If you use this
        component to patch between different view actions, this should be the
        `@live_action` attribute.
        """

      attr :rest, :global, doc: "Any additional HTML attributes."

      slot :item, required: true do
        attr :href, :string, doc: "Passed to `Phoenix.Component.link/1`."
        attr :navigate, :string, doc: "Passed to `Phoenix.Component.link/1`."
        attr :patch, :string, doc: "Passed to `Phoenix.Component.link/1`."

        attr :value, :any,
          doc: """
          The value of the item is compared to the `current_value` attribute to
          determine whether to add the `aria-current` attribute. This can be a
          single value or a list of values, e.g. multiple live actions for which
          the item should be marked as current.
          """
      end
    end
  end

  @impl true
  def init_block(_opts, _extra) do
    []
  end

  @impl true
  def render(assigns) do
    ~H"""
    <nav aria-label={@label} class={@class} {@rest}>
      <ul>
        <li :for={item <- @item}>
          <.link
            href={item[:href]}
            navigate={item[:navigate]}
            patch={item[:patch]}
            aria-current={@current_value in List.wrap(item.value) && "page"}
          >
            <%= render_slot(item) %>
          </.link>
        </li>
      </ul>
    </nav>
    """
  end
end
