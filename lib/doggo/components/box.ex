defmodule Doggo.Components.Box do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    Renders a box for a section on the page.
    """
  end

  @impl true
  def usage do
    """
    Minimal example with only a box body:

    ```heex
    <.box>
      <p>This is a box.</p>
    </.box>
    ```

    With title, banner, action, and footer:

    ```heex
    <.box>
      <:title>Profile</:title>
      <:banner>
        <img src="banner-image.png" alt="" />
      </:banner>
      <:action>
        <button_link patch={~p"/profiles/\#{@profile}/edit"}>Edit</button_link>
      </:action>

      <p>This is a profile.</p>

      <:footer>
        <p>Last edited: <%= @profile.updated_at %></p>
      </:footer>
    </.box>
    ```
    """
  end

  @impl true
  def css_path do
    "components/_box.scss"
  end

  @impl true
  def config do
    [
      type: :layout,
      since: "0.6.0",
      maturity: :developing,
      modifiers: []
    ]
  end

  @impl true
  def nested_classes(base_class) do
    [
      "#{base_class}-actions",
      "#{base_class}-banner",
      "#{base_class}-body"
    ]
  end

  @impl true
  def attrs_and_slots do
    quote do
      slot :title, doc: "The title for the box."

      slot :inner_block,
        required: true,
        doc: "Slot for the content of the box body."

      slot :action, doc: "A slot for action buttons related to the box."

      slot :banner,
        doc: "A slot that can be used to render a banner image in the header."

      slot :footer, doc: "An optional slot for the footer."

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
    <section class={@class} {@rest}>
      <header :if={@title != [] || @banner != [] || @action != []}>
        <h2 :if={@title != []}><%= render_slot(@title) %></h2>
        <div :if={@action != []} class={"#{@base_class}-actions"}>
          <%= for action <- @action do %>
            <%= render_slot(action) %>
          <% end %>
        </div>
        <div :if={@banner != []} class={"#{@base_class}-banner"}>
          <%= render_slot(@banner) %>
        </div>
      </header>
      <div class={"#{@base_class}-body"}>
        <%= render_slot(@inner_block) %>
      </div>
      <footer :if={@footer != []}>
        <%= render_slot(@footer) %>
      </footer>
    </section>
    """
  end
end
