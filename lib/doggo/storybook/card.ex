defmodule Doggo.Storybook.Card do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def layout, do: :one_column

  def template do
    """
    <div style="inline-size: 20rem">
      <.psb-variation/>
    </div>
    """
  end

  def variations(_opts) do
    [
      %Variation{
        id: :default,
        slots: [image(), header(), body(), footer()]
      },
      %Variation{
        id: :without_image,
        slots: [header(), body(), footer()]
      },
      %Variation{
        id: :without_footer,
        slots: [image(), header(), body()]
      },
      %Variation{
        id: :body_only,
        slots: [body()]
      }
    ]
  end

  def modifier_variation_base(_id, _name, _value, _opts) do
    %{
      slots: [image(), header(), body(), footer()]
    }
  end

  defp image do
    """
    <:image>
      <img
        src="https://github.com/woylie/doggo/blob/main/assets/images/dog_1.webp?raw=true"
        alt="A gray-muzzled dog in a camouflage coat and harness."
      />
    </:image>
    """
  end

  defp header do
    """
    <:header><h2>Dog Fashion Show</h2></:header>
    """
  end

  defp body do
    """
    <:body>
      The next dog fashion show is coming up quickly. Here's what you need
      to look out for.
    </:body>
    """
  end

  defp footer do
    """
    <:footer>
      <span>2023-11-15 12:24</span>
      <span>Events</span>
    </:footer>
    """
  end
end
