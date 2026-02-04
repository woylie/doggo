defmodule Doggo.Components.Avatar do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    Renders profile picture, typically to represent a user.
    """
  end

  @impl true
  def usage do
    """
    Minimal example with only the `src` attribute:

    ```heex
    <.avatar src="avatar.png" />
    ```

    Render avatar as a circle:

    ```heex
    <.avatar src="avatar.png" circle />
    ```

    Use a placeholder image in case the avatar is not set:

    ```heex
    <.avatar src={@user.avatar_url} placeholder_src="fallback.png" />
    ```

    Render an text as the placeholder value:

    ```heex
    <.avatar src={@user.avatar_url} placeholder_content="A" />
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
        size: [
          values: ["small", "normal", "medium", "large"],
          default: "normal"
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
      attr :src, :any,
        default: nil,
        doc: """
        The URL of the avatar image. If `nil`, the component will use the value
        provided in the placeholder attribute.
        """

      attr :placeholder_src, :any,
        default: nil,
        doc: """
        Fallback image src to use in case the `src` attribute is `nil`.

        If neither `placeholder_src` nor `placeholder_text` are set and the
        `src` is `nil`, no element will be rendered.
        """

      attr :placeholder_content, :any,
        default: nil,
        doc: """
        Fallback content to render in case the `src` attribute is `nil`,
        such as text initials or inline SVG.

        If `placeholder_src` is set, this attribute is ignored.

        If neither `placeholder_src` nor `placeholder_text` are set and the
        `src` is `nil`, no element will be rendered.
        """

      attr :alt, :string,
        default: "",
        doc: """
        Use alt text to identify the individual in an avatar if their name or
        identifier isn't otherwise provided in adjacent text. In contexts where
        the user's name or identifying information is already displayed alongside
        the avatar, use `alt=""` (the default) to avoid redundancy and treat the
        avatar as a decorative element for screen readers.
        """

      attr :loading, :string, values: ["eager", "lazy"], default: "lazy"
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
    <div
      :if={@src || @placeholder_src || @placeholder_content}
      class={@class}
      {@data_attrs}
      {@rest}
    >
      <.inner_avatar
        src={@src}
        placeholder_src={@placeholder_src}
        placeholder_content={@placeholder_content}
        alt={@alt}
        loading={@loading}
      />
    </div>
    """
  end

  defp inner_avatar(%{src: src} = assigns) when is_binary(src) do
    ~H"""
    <img src={@src} alt={@alt} loading={@loading} />
    """
  end

  defp inner_avatar(%{placeholder_src: src} = assigns) when is_binary(src) do
    ~H"""
    <img src={@placeholder_src} alt={@alt} loading={@loading} />
    """
  end

  defp inner_avatar(assigns) do
    ~H"""
    <span>{@placeholder_content}</span>
    """
  end
end
