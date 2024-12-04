defmodule Doggo.Components.Fallback do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    The fallback component renders a given value unless it is empty, in which case
    it renders a fallback value instead.

    The values `nil`, `""`, `[]` and `%{}` are treated as empty values.

    This component optionally applies a formatter function to non-empty values.

    The primary purpose of this component is to enhance accessibility. In
    situations where a value in a table column or property list is set to be
    invisible or not displayed, it's crucial to provide an alternative text for
    screen readers.
    """
  end

  @impl true
  def usage do
    """
    Render the value of `@some_value` if it's available, or display the
    default placeholder otherwise:

    ```heex
    <.fallback value={@some_value} />
    ```

    Apply a formatter function to `@some_value` if it is not `nil`:

    ```heex
    <.fallback value={@some_value} formatter={&format_date/1} />
    ```

    Set a custom placeholder and text for screen readers:

    ```heex
    <.fallback
      value={@some_value}
      placeholder="n/a"
      accessibility_text="not available"
    />
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
      attr :value, :any,
        required: true,
        doc: """
        The value to display. If the value is `nil`, `""`, `[]` or `%{}`, the
        placeholder is rendered instead.
        """

      attr :formatter, :any,
        default: nil,
        doc: """
        A 1-arity function that takes the value and returns the value for display.
        The formatter function is only applied if `value` is not an empty value.
        """

      attr :placeholder, :any,
        default: "-",
        doc: """
        The placeholder to render if the `value` is empty.
        """

      attr :accessibility_text, :string,
        default: "not set",
        doc: """
        The text for the `aria-label` attribute in case the `value` is empty.
        """

      attr :rest, :global, doc: "Any additional HTML attributes."
    end
  end

  @impl true
  def init_block(_opts, _extra) do
    []
  end

  @impl true
  def render(%{value: value, formatter: formatter} = assigns) do
    value =
      cond do
        value in [nil, "", [], %{}] -> nil
        is_nil(formatter) -> value
        true -> formatter.(value)
      end

    assigns = assign(assigns, :value, value)

    ~H"""
    {@value}<span
      :if={is_nil(@value)}
      class={@class}
      aria-label={@accessibility_text}
      {@rest}
      phx-no-format
    >{@placeholder}</span>
    """
  end
end
