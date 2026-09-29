defmodule Doggo.Components.Image do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    Renders an image with an optional caption.

    The component uses the `frame` component for the image's box. The `frame`
    needs to be built before the `image`.

    ```elixir
    build_frame()
    build_image()
    ```

    To use a frame build with a different name, set the `frame` option.

    ```elixir
    build_frame(name: :media_frame, ratios: ["21:9"])
    build_image(frame: &__MODULE__.media_frame/1)
    ```
    """
  end

  @impl true
  def builder_doc do
    """
    - `:frame` - The build of the `frame` component that renders the image's
      box, as a remote capture. Defaults to `&__MODULE__.frame/1`, the frame
      built in the same module under its default name.
    """
  end

  @impl true
  def usage do
    """
    ```heex
    <.image
      src="https://github.com/woylie/doggo/blob/main/assets/images/dog_1.webp?raw=true"
      alt="A gray-muzzled dog in a camouflage coat and harness."
      ratio="16:9"
    >
      <:caption>
        Canine couture, spring collection: the season's boldest silhouettes, worn
        on four legs.
      </:caption>
    </.image>
    ```
    """
  end

  @impl true
  def css_path do
    "components/image.css"
  end

  @impl true
  def config do
    [
      type: :media,
      since: "0.6.0",
      maturity: :developing,
      modifiers: [],
      extra: [
        frame: nil
      ]
    ]
  end

  @impl true
  def callees, do: [frame: :frame]

  @impl true
  def nested_classes(base_class) do
    [
      "#{base_class}-frame"
    ]
  end

  @impl true
  def attrs_and_slots(opts) do
    ratios = get_in(opts, [:callees, :frame, :extra, :ratios])

    quote do
      attr :ratio, :string,
        values: unquote([nil | ratios]),
        default: nil,
        doc: """
        The aspect ratio of the image's box. The value is passed to the
        `frame` component.
        """

      attr :src, :string,
        required: true,
        doc: "The URL of the image to render."

      attr :srcset, :any,
        default: nil,
        doc: """
        A set of image URLs in different sizes. Can be passed as a string or a
        map.

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
        Specifies media conditions for the image widths, if the `srcset`
        attribute uses intrinsic widths.

        See https://developer.mozilla.org/en-US/docs/Web/API/HTMLImageElement/sizes.
        """

      attr :alt, :string,
        required: true,
        doc: """
        A text description of the image for screen reader users and those with
        slow internet. Effective alt text should concisely capture the image's
        essence and function, considering its context within the content. Aim
        for clarity and inclusivity without repeating information already
        conveyed by surrounding text, and avoid starting with "Image of" as
        screen readers automatically announce image presence.
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
  def template(_opts) do
    quote do
      ~H"""
      <figure
        class={[Doggo.build(:base_class) | List.wrap(@class)]}
        {@data_attrs}
        {@rest}
      >
        <Doggo.Callee.frame ratio={@ratio} class={Doggo.build(:base_class, "-frame")}>
          <img
            src={@src}
            width={@width}
            height={@height}
            alt={@alt}
            loading={@loading}
            srcset={Doggo.Components.Image.build_srcset(@srcset)}
            sizes={@sizes}
          />
        </Doggo.Callee.frame>
        <figcaption :if={@caption != []}>{render_slot(@caption)}</figcaption>
      </figure>
      """
    end
  end

  @doc false
  def build_srcset(nil), do: nil
  def build_srcset(srcset) when is_binary(srcset), do: srcset

  def build_srcset(%{} = srcset) do
    Enum.map_join(srcset, ", ", fn {width_or_density, url} ->
      "#{url} #{width_or_density}"
    end)
  end
end
