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
        ratios: ~w(1:1 3:2 2:3 4:3 3:4 5:4 4:5 16:9 9:16)
      ]
    ]
  end

  @impl true
  def nested_classes(_) do
    []
  end

  @impl true
  def attrs_and_slots(opts) do
    ratios = validate_ratios!(Keyword.fetch!(opts, :ratios))

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
  def template(opts) do
    ratio_parts =
      opts |> Keyword.fetch!(:ratios) |> ratio_parts() |> Macro.escape()

    quote do
      {numerator, denominator} =
        Map.get(unquote(ratio_parts), var!(assigns).ratio, {nil, nil})

      var!(assigns) =
        Doggo.assign_derived(
          var!(assigns),
          [numerator: numerator, denominator: denominator],
          [:ratio]
        )

      ~H"""
      <div
        class={[Doggo.build(:base_class) | List.wrap(@class)]}
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

  defp validate_ratios!(ratios) do
    if is_list(ratios) and ratios != [] and Enum.all?(ratios, &split_ratio/1) do
      ratios
    else
      raise ArgumentError, """
      invalid ratios option for build_frame/1

      The option has to be a non-empty list of strings in the format n:d, e.g.
      ["16:9", "4:3"].

      Got:

          #{inspect(ratios)}
      """
    end
  end

  defp ratio_parts(ratios), do: Map.new(ratios, &{&1, split_ratio(&1)})

  defp split_ratio(ratio) when is_binary(ratio) do
    with [n, d] <- String.split(ratio, ":"),
         {n, ""} when n > 0 <- Integer.parse(n),
         {d, ""} when d > 0 <- Integer.parse(d) do
      {Integer.to_string(n), Integer.to_string(d)}
    else
      _ -> nil
    end
  end

  defp split_ratio(_), do: nil
end
