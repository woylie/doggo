defmodule Doggo.Components.Image do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    Renders an image with an optional caption.
    """
  end

  @impl true
  def usage do
    """
    ```heex
    <.image
      src="https://github.com/woylie/doggo/blob/main/assets/dog_poncho.jpg?raw=true"
      alt="A dog wearing a colorful poncho walks down a fashion show runway."
      ratio={{16, 9}}
    >
      <:caption>
        Spotlight on canine couture: A dog fashion show where four-legged models
        dazzle the runway with the latest in pet apparel.
      </:caption>
    </.image>
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
            "1:1",
            "3:2",
            "2:3",
            "4:3",
            "3:4",
            "5:4",
            "4:5",
            "16:9",
            "9:16"
          ],
          default: nil
        ]
      ]
    ]
  end

  @impl true
  def nested_classes(base_class) do
    [
      "#{base_class}-frame"
    ]
  end

  @impl true
  def attrs_and_slots do
    quote do
      attr :src, :string,
        required: true,
        doc: "The URL of the image to render."

      attr :srcset, :any,
        default: nil,
        doc: """
        A set of image URLs in different sizes. Can be passed as a string or a map.

        For example, this map:

            %{
              "1x" => "images/image-1x.jpg",
              "2x" => "images/image-2x.jpg"
            }

        Will result in this `srcset`:

            "images/image-1x.jpg 1x, images/image-2x.jpg 2x"

        See https://developer.mozilla.org/en-US/docs/Web/API/HTMLImageElement/srcset.
        """

      attr :sizes, :string,
        default: nil,
        doc: """
        Specifies media conditions for the image widths, if the `srcset` attribute
        uses intrinsic widths.

        See https://developer.mozilla.org/en-US/docs/Web/API/HTMLImageElement/sizes.
        """

      attr :alt, :string,
        required: true,
        doc: """
        A text description of the image for screen reader users and those with slow
        internet. Effective alt text should concisely capture the image's essence
        and function, considering its context within the content. Aim for clarity
        and inclusivity without repeating information already conveyed by
        surrounding text, and avoid starting with "Image of" as screen readers
        automatically announce image presence.
        """

      attr :width, :integer, default: nil
      attr :height, :integer, default: nil
      attr :loading, :string, values: ["eager", "lazy"], default: "lazy"
      attr :rest, :global, doc: "Any additional HTML attributes."

      slot :caption
    end
  end

  @impl true
  def init_block(_opts, _extra) do
    []
  end

  @impl true
  def render(assigns) do
    ~H"""
    <figure class={@class} {@rest}>
      <div class={"#{@base_class}-frame"}>
        <img
          src={@src}
          width={@width}
          height={@height}
          alt={@alt}
          loading={@loading}
          srcset={build_srcset(@srcset)}
          sizes={@sizes}
        />
      </div>
      <figcaption :if={@caption != []}>{render_slot(@caption)}</figcaption>
    </figure>
    """
  end

  defp build_srcset(nil), do: nil
  defp build_srcset(srcset) when is_binary(srcset), do: srcset

  defp build_srcset(%{} = srcset) do
    Enum.map_join(srcset, ", ", fn {width_or_density, url} ->
      "#{url} #{width_or_density}"
    end)
  end
end
