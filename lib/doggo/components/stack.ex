defmodule Doggo.Components.Stack do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    Applies a vertical margin between the child elements.
    """
  end

  @impl true
  def builder_doc do
    """
    - `:recursive_class` - This class is added if `:recursive` is set to `true`.
    """
  end

  @impl true
  def usage do
    """
    ```heex
    <.stack>
      <div>some block</div>
      <div>some other block</div>
    </.stack>
    ```

    By default, the margin is only applied to the direct children of the
    component. To apply a vertical margin on children at any nesting level, set
    the `recursive` attribute.

    ```heex
    <.stack recursive>
      <div>
        <div>some nested block</div>
        <div>another nested block</div>
      </div>
      <div>some other block</div>
    </.stack>
    ```
    """
  end

  @impl true
  def css_path do
    "layouts/_stack.scss"
  end

  @impl true
  def config do
    [
      type: :layout,
      since: "0.6.0",
      maturity: :stable,
      modifiers: [],
      extra: [recursive_class: "is-recursive"]
    ]
  end

  @impl true
  def nested_classes(_) do
    []
  end

  @impl true
  def attrs_and_slots do
    quote do
      attr :recursive, :boolean,
        default: false,
        doc:
          "If `true`, the stack margins will be applied to nested children as well."

      attr :rest, :global, doc: "Any additional HTML attributes."

      slot :inner_block, required: true
    end
  end

  @impl true
  def init_block(_opts, extra) do
    recursive_class = Keyword.fetch!(extra, :recursive_class)

    quote do
      var!(assigns) =
        if var!(assigns)[:recursive] do
          Map.update!(
            var!(assigns),
            :class,
            &(&1 ++ [unquote(recursive_class)])
          )
        else
          var!(assigns)
        end
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class={@class} {@rest}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
end
