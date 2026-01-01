defmodule Doggo.Components.PageHeader do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    Renders a header that is specific to the content of the current page.

    Unlike a site-wide header, which offers consistent navigation and elements
    like logos throughout the website or application, this component is meant
    to describe the unique content of each page. For instance, on an article page,
    it would display the article's title.

    It is typically used as a direct child of the `<main>` element.
    """
  end

  @impl true
  def usage do
    """
    ```heex
    <main>
      <.page_header title="Puppy Profiles" subtitle="Share Your Pup's Story">
        <:action>
          <.button_link patch={~p"/puppies/new"}>Add New Profile</.button_link>
        </:action>
      </.page_header>

      <section>
        <!-- Content -->
      </section>
    </main>
    ```

    With back link:

    ```heex
    <main>
      <.page_header title="Puppy Profile">
        <:navigation navigate={~p"/puppies"}>
          Back to puppy list
        </:navigation>
        <:action>
          <.button_link patch={~p"/puppies/new"}>Add New Profile</.button_link>
        </:action>
      </.page_header>

      <section>
        <!-- Content -->
      </section>
    </main>
    ```
    """
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
      "#{base_class}-navigation",
      "#{base_class}-title"
    ]
  end

  @impl true
  def attrs_and_slots do
    quote do
      attr :title, :string,
        required: true,
        doc: "The title for the current page."

      attr :subtitle, :string, default: nil, doc: "An optional sub title."

      attr :rest, :global, doc: "Any additional HTML attributes."

      slot :navigation,
        doc: """
        Slot for a single link rendered before the title, typically used for a
        back link.
        """ do
        attr :label, :string,
          doc: """
          Optional aria label for the link. Use if the link has no text content.
          """

        attr :href, :string
        attr :navigate, :string
        attr :patch, :string
      end

      slot :action,
        doc: "A slot for action buttons related to the current page."
    end
  end

  @impl true
  def init_block(_opts, _extra) do
    []
  end

  @impl true
  def render(assigns) do
    ~H"""
    <header class={@class} {@rest}>
      <div :if={@navigation != []} class={"#{@base_class}-navigation"}>
        <.link
          :for={navigation <- @navigation}
          href={navigation[:href]}
          navigate={navigation[:navigate]}
          patch={navigation[:patch]}
          phx-click={navigation[:on_click]}
          aria-label={navigation[:label]}
        >
          {render_slot(navigation)}
        </.link>
      </div>
      <div class={"#{@base_class}-title"}>
        <h1>{@title}</h1>
        <p :if={@subtitle}>{@subtitle}</p>
      </div>
      <div :if={@action != []} class={"#{@base_class}-actions"}>
        <%= for action <- @action do %>
          {render_slot(action)}
        <% end %>
      </div>
    </header>
    """
  end
end
