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
  def config do
    [
      type: :navigation,
      since: "0.6.0",
      maturity: :developing,
      modifiers: []
    ]
  end

  @impl true
  def nested_classes(_) do
    []
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
  def init_block(_opts, _extra) do
    []
  end

  @impl true
  def example_label, do: "Breadcrumb"

  @impl true
  def render(%{item: item} = assigns) do
    [last_item | rest] = Enum.reverse(item)

    assigns =
      assign(
        assigns,
        :item,
        Enum.reverse([{:current, last_item} | rest])
      )

    ~H"""
    <nav
      aria-label={@label}
      aria-labelledby={@labelledby}
      class={@class}
      {@data_attrs}
      {@rest}
    >
      <ol>
        <li :for={current_item <- @item}>
          <.breadcrumb_link item={current_item} />
        </li>
      </ol>
    </nav>
    """
  end

  defp breadcrumb_link(%{item: {:current, current_item}} = assigns) do
    assigns = assign(assigns, :item, current_item)

    ~H"""
    <.link
      navigate={@item[:navigate]}
      patch={@item[:patch]}
      href={@item[:href]}
      aria-current="page"
    >
      {render_slot(@item)}
    </.link>
    """
  end

  defp breadcrumb_link(assigns) do
    ~H"""
    <.link navigate={@item[:navigate]} patch={@item[:patch]} href={@item[:href]}>
      {render_slot(@item)}
    </.link>
    """
  end
end
