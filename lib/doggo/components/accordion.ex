defmodule Doggo.Components.Accordion do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    Renders a set of headings that control the visibility of their content
    sections.
    """
  end

  @impl true
  def usage do
    """
    ```heex
    <.accordion id="dog-breeds">
      <:section title="Golden Retriever">
        <p>
          Friendly, intelligent, great with families. Origin: Scotland. Needs
          regular exercise.
        </p>
      </:section>
      <:section title="Siberian Husky">
        <p>
          Energetic, outgoing, distinctive appearance. Origin: Northeast Asia.
          Loves cold climates.
        </p>
      </:section>
      <:section title="Dachshund">
        <p>
          Playful, stubborn, small size. Origin: Germany. Enjoys sniffing games.
        </p>
      </:section>
    </.accordion>
    ```

    This component needs the `Doggo.Accordion` JavaScript hook for the arrow
    keys. See [Phoenix LiveView Hooks](readme.html#phoenix-liveview-hooks) for
    registering it.
    """
  end

  @impl true
  def keyboard do
    """
    - `Enter` or `Space` - toggle the section of the focused header.
    - `Up` and `Down` - move to the previous or the next header, wrapping at the
      ends.
    - `Home` and `End` - first and last header.

    Every header is in the tab order, which is what the ARIA Authoring Practices
    describe for an accordion. The arrow keys, `Home` and `End` need the
    colocated hook; the ARIA Authoring Practices list them as optional for an
    accordion.
    """
  end

  @impl true
  def config do
    [
      type: :data,
      since: "0.6.0",
      maturity: :developing,
      maturity_note: """
      **The markup may change.** Replacing the `div`, `button` and
      `aria-expanded` with the platform's own `<details>` and `<summary>` is
      under consideration. It would need no JavaScript, and it would change the
      elements this component emits and the attributes your stylesheet targets.
      """,
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
      attr :id, :string, required: true

      attr :expanded, :atom,
        values: [:all, :none, :first],
        default: :all,
        doc: """
        Defines how the accordion sections are initialized.

        - `:all` - All accordion sections are expanded by default.
        - `:none` - All accordion sections are hidden by default.
        - `:first` - Only the first accordion section is expanded by default.
        """

      attr :heading, :string,
        default: "h3",
        values: ["h2", "h3", "h4", "h5", "h6"],
        doc: """
        The heading level for the section title (trigger).
        """

      attr :rest, :global, doc: "Any additional HTML attributes."

      slot :section, required: true do
        attr :title, :string
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
    <div id={@id} class={@class} phx-hook="Doggo.Accordion" {@data_attrs} {@rest}>
      <.section
        :for={{section, index} <- Enum.with_index(@section, 1)}
        section={section}
        index={index}
        id={@id}
        expanded={@expanded}
        heading={@heading}
      />
    </div>
    """
  end

  @doc false
  def section(
        %{
          index: index,
          expanded: expanded_initial
        } = assigns
      ) do
    expanded = section_expanded?(index, expanded_initial)
    assigns = assign(assigns, aria_expanded: to_string(expanded))

    ~H"""
    <div>
      <.dynamic_tag tag_name={@heading}>
        <button
          id={"#{@id}-trigger-#{@index}"}
          type="button"
          aria-expanded={@aria_expanded}
          aria-controls={"#{@id}-section-#{@index}"}
          phx-click={Doggo.toggle_accordion_section(@id, @index)}
        >
          <span>{@section.title}</span>
        </button>
      </.dynamic_tag>
      <div
        id={"#{@id}-section-#{@index}"}
        role="region"
        aria-labelledby={"#{@id}-trigger-#{@index}"}
        hidden={@aria_expanded != "true"}
      >
        {render_slot(@section)}
      </div>
    </div>
    """
  end

  @doc false
  def section_expanded?(_, :all), do: true
  def section_expanded?(_, :none), do: false
  def section_expanded?(1, :first), do: true
  def section_expanded?(_, :first), do: false
end
