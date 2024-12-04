defmodule Doggo.Components.Card do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    Renders a card in an `article` tag, typically used repetitively in a grid or
    flex box layout.
    """
  end

  @impl true
  def usage do
    """
    ```heex
    <.card>
      <:image>
        <img src="image.png" alt="Picture of a dog dressed in a poncho." />
      </:image>
      <:header><h2>Dog Fashion Show</h2></:header>
      <:main>
        The next dog fashion show is coming up quickly. Here's what you need
        to look out for.
      </:main>
      <:footer>
        <span>2023-11-15 12:24</span>
        <span>Events</span>
      </:footer>
    </.card>
    ```
    """
  end

  @impl true
  def config do
    [
      type: :data,
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
      attr :rest, :global, doc: "Any additional HTML attributes."

      slot :image,
        doc: """
        An optional image slot. The slot content will be rendered within a figure
        element.
        """

      slot :header,
        doc: """
        The header of the card. You typically want to wrap the header in a `h2` or
        `h3` tag, or another header level, depending on the hierarchy on the page.
        """

      slot :main, doc: "The main content of the card."

      slot :footer,
        doc: """
        A footer of the card, typically containing controls, tags, or meta
        information.
        """
    end
  end

  @impl true
  def init_block(_opts, _extra) do
    []
  end

  @impl true
  def render(assigns) do
    ~H"""
    <article class={@class} {@rest}>
      <figure :if={@image != []}>{render_slot(@image)}</figure>
      <header :if={@header != []}>{render_slot(@header)}</header>
      <main :if={@main != []}>{render_slot(@main)}</main>
      <footer :if={@footer != []}>{render_slot(@footer)}</footer>
    </article>
    """
  end
end
