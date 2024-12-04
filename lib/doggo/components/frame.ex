defmodule Doggo.Components.Frame do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    Renders a frame with an aspect ratio for images or videos.
    """
  end

  @impl true
  def usage do
    """
    Rendering an image with the aspect ratio 4:3.

    ```heex
    <.frame ratio={{4, 3}}>
      <img src="image.png" alt="An example image illustrating the usage." />
    </.frame>
    ```

    Rendering an image as a circle.

    ```heex
    <.frame circle>
      <img src="image.png" alt="An example image illustrating the usage." />
    </.frame>
    ```
    """
  end

  @impl true
  def config do
    [
      type: :media,
      since: "0.6.0",
      maturity: :developing,
      modifiers: [
        ratio: [
          values: [
            nil,
            "1-by-1",
            "3-by-2",
            "2-by-3",
            "4-by-3",
            "3-by-4",
            "5-by-4",
            "4-by-5",
            "16-by-9",
            "9-by-16"
          ],
          default: nil
        ],
        shape: [values: [nil, "circle"], default: nil]
      ]
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
      slot :inner_block
    end
  end

  @impl true
  def init_block(_opts, _extra) do
    []
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class={@class} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end
end
