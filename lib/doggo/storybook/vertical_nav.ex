defmodule Doggo.Storybook.VerticalNav do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def dependent_components, do: [:vertical_nav_nested, :vertical_nav_section]

  def template do
    """
    <div style="inline-size: 16rem">
      <.psb-variation/>
    </div>
    """
  end

  def variations(opts) do
    [
      %Variation{
        id: :default,
        attributes: %{
          id: "vertical-nav-main",
          label: "Main"
        },
        slots: slots("vertical-nav-main", opts)
      },
      %Variation{
        id: :with_section,
        note: section_note(opts),
        attributes: %{
          id: "sectioned-nav",
          label: "Main"
        },
        template: section_template(opts),
        slots: slots("sectioned-nav", opts)
      },
      %Variation{
        id: :without_landmark,
        description: "Without landmark",
        note:
          "With `landmark={false}`, the component renders a `<div>`, and the label names the list. Use it when rendering the component inside an existing navigation landmark.",
        attributes: %{
          id: "vertical-nav-inner",
          label: "Projects",
          landmark: false
        },
        template: """
        <nav aria-label="Main" style="inline-size: 16rem">
          <.psb-variation/>
        </nav>
        """,
        slots: slots("vertical-nav-inner", opts)
      }
    ]
  end

  defp section_note(opts) do
    note = "A section contains one or more items that are not navigation links."

    if opts[:dependent_components][:vertical_nav_section] do
      note
    else
      note <>
        " This example cannot be fully rendered because the `vertical_nav_section` component is not compiled."
    end
  end

  defp section_template(opts) do
    if fun = opts[:dependent_components][:vertical_nav_section] do
      """
      <div style="display: grid; gap: 1.5rem; inline-size: 16rem">
        <.psb-variation/>
        <.#{fun} id="sectioned-nav-search">
          <:title>Search</:title>
          <:item><input type="search" placeholder="Search" aria-label="Search" /></:item>
        </.#{fun}>
      </div>
      """
    else
      :unset
    end
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
