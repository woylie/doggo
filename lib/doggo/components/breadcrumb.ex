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
    <.breadcrumb>
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
  def attrs_and_slots do
    quote do
      attr :label, :string,
        default: "Breadcrumb",
        doc: """
        The aria label for the `<nav>` element.

        The label should start with a capital letter, be localized, and should
        not repeat the word 'navigation'.
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
  def render(%{item: item} = assigns) do
    [last_item | rest] = Enum.reverse(item)

    assigns =
      assign(
        assigns,
        :item,
        Enum.reverse([{:current, last_item} | rest])
      )

    ~H"""
    <nav aria-label={@label} class={@class} {@data_attrs} {@rest}>
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
