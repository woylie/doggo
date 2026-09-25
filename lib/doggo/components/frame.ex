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
  def builder_doc do
    """
    - `:ratios` - The aspect ratios the `ratio` attribute accepts, as strings in
      the format `n:d`. The first one is the default.
    """
  end

  @impl true
  def usage do
    """
    Rendering an image with the aspect ratio 4:3.

    ```heex
    <.frame ratio="4:3">
      <img src="image.png" alt="An example image illustrating the usage." />
    </.frame>
    ```

    Rendering an image as a circle.

    ```heex
    <.frame shape="circle">
      <img src="image.png" alt="An example image illustrating the usage." />
    </.frame>
    ```
    """
  end

  @impl true
  def css_path do
    "components/frame.css"
  end

  @impl true
  def config do
    [
      type: :media,
      since: "0.6.0",
      maturity: :developing,
      modifiers: [
        shape: [values: [nil, "circle"], default: nil]
      ],
      extra: [
        ratios: Doggo.default_ratios()
      ]
    ]
  end

  @impl true
  def nested_classes(_) do
    []
  end

  @impl true
  def attrs_and_slots(opts) do
    ratios = Doggo.validate_ratios!(:build_frame, Keyword.fetch!(opts, :ratios))

    quote do
      attr :ratio, :string,
        values: unquote(ratios),
        default: unquote(hd(ratios)),
        doc: """
        The aspect ratio, rendered as `data-numerator` and `data-denominator`.
        """

      attr :rest, :global, doc: "Any additional HTML attributes."
      slot :inner_block
    end
  end

  @impl true
  def init_block(_opts, extra) do
    ratio_parts =
      extra |> Keyword.fetch!(:ratios) |> Doggo.ratio_parts() |> Macro.escape()

    quote do
      {numerator, denominator} =
        Map.get(unquote(ratio_parts), var!(assigns).ratio, {nil, nil})

      var!(assigns) =
        assign(var!(assigns), numerator: numerator, denominator: denominator)
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div
      class={@class}
      data-numerator={@numerator}
      data-denominator={@denominator}
      {@data_attrs}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end
end
