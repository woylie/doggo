defmodule Doggo.Components.Breadcrumb do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    Renders a breadcrumb navigation.
    """
  end

  @impl true
  def usage do
    """
    ```heex
    <.breadcrumb label="Breadcrumb">
      <:item patch="/categories">Categories</:item>
      <:item patch="/categories/1">Reviews</:item>
      <:item patch="/categories/1/articles/1">The Movie</:item>
    </.breadcrumb>
    ```
    """
  end

  @impl true
  def css_path do
    "components/breadcrumb.css"
  end

  @impl true
  def config do
    [
      type: :navigation,
      since: "0.6.0",
      maturity: :developing,
      modifiers: []
    ]
  end

  @impl true
  def own_attributes, do: ["aria-label": :label]

  @impl true
  def nested_classes(base_class) do
    ["#{base_class}-item", "#{base_class}-link"]
  end

  @impl true
  def attrs_and_slots(_opts) do
    quote do
      attr :label, :string,
        default: nil,
        doc: """
        The aria label for the `<nav>` element. It should start with a capital
        letter and be localized.

        Do not repeat the word `navigation` in the label. Screen readers
        announce the role along with the name. Using the role in the label
        would make screen readers repeat it.
        """

      attr :labelledby, :string,
        default: nil,
        doc: """
        The DOM ID of an element that labels this navigation.

        Set either this attribute or `label`.
        """

      attr :rest, :global, doc: "Any additional HTML attributes."

      slot :item, required: true do
        attr :navigate, :string
        attr :patch, :string
        attr :href, :string
      end
    end
  end

  @impl true
  def example_label, do: "Breadcrumb"

  @impl true
  def template(_opts) do
    quote do
      var!(assigns) =
        case var!(assigns).item do
          [] ->
            var!(assigns)

          item ->
            [last_item | rest] = Enum.reverse(item)

            Doggo.assign_derived(
              var!(assigns),
              [item: Enum.reverse([{:current, last_item} | rest])],
              [:item]
            )
        end

      ~H"""
      <nav
        :if={@item != []}
        aria-label={@label}
        aria-labelledby={@labelledby}
        class={[Doggo.build(:base_class) | List.wrap(@class)]}
        {@data_attrs}
        {@rest}
      >
        <ol>
          <li :for={current_item <- @item} class={Doggo.build(:base_class, "-item")}>
            <Doggo.Components.Breadcrumb.breadcrumb_link
              item={current_item}
              base_class={Doggo.build(:base_class)}
            />
          </li>
        </ol>
      </nav>
      """
    end
  end

  @doc false
  def breadcrumb_link(%{item: {:current, current_item}} = assigns) do
    assigns = assign(assigns, :item, current_item)

    ~H"""
    <.link
      navigate={@item[:navigate]}
      patch={@item[:patch]}
      href={@item[:href]}
      class={"#{@base_class}-link"}
      aria-current="page"
    >
      {render_slot(@item)}
    </.link>
    """
  end

  def breadcrumb_link(assigns) do
    ~H"""
    <.link
      navigate={@item[:navigate]}
      patch={@item[:patch]}
      href={@item[:href]}
      class={"#{@base_class}-link"}
    >
      {render_slot(@item)}
    </.link>
    """
  end
end
