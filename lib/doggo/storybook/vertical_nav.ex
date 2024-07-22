defmodule Doggo.Storybook.VerticalNav do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def dependent_components, do: [:vertical_nav_nested, :vertical_nav_section]

  def variations(opts) do
    [
      %Variation{
        id: :default,
        attributes: %{
          id: "main-nav",
          label: "Main"
        },
        slots: slots("main-nav", opts)
      }
    ]
  end

  def modifier_variation_base(id, _name, _value, opts) do
    %{
      attributes: %{
        id: id,
        label: "Main"
      },
      slots: slots(id, opts)
    }
  end

  defp slots(id, opts) do
    dependent_components = opts[:dependent_components]
    nested_fun = dependent_components[:vertical_nav_nested]

    nested =
      if nested_fun do
        """
        <.#{nested_fun} id="#{id}-content">
          <:title>Content</:title>
          <:item current_page>
            <Phoenix.Component.link navigate="/posts">
              Posts
            </Phoenix.Component.link>
          </:item>
          <:item>
            <Phoenix.Component.link navigate="/comments">
              Comments
            </Phoenix.Component.link>
          </:item>
        </.#{nested_fun}>
        """
      else
        """
        <p>Please compile the <code>vertical_nav_nested</code> component for a complete preview.</p>
        """
      end

    [
      """
      <:item>
        <Phoenix.Component.link navigate="/dashboard">
          Dashboard
        </Phoenix.Component.link>
      </:item>
      """,
      """
      <:item>
        #{nested}
      </:item>
      """
    ]
  end
end
