defmodule Doggo.Storybook.Drawer do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def dependent_components,
    do: [:vertical_nav, :vertical_nav_nested, :vertical_nav_section]

  def layout, do: :one_column

  def template do
    """
    <div style="display: flex; align-self: stretch; block-size: 32rem">
      <div style="inline-size: 16rem; flex: none">
        <.psb-variation/>
      </div>
      <p style="min-inline-size: 0; padding: 1rem">Page content sits beside the drawer.</p>
    </div>
    """
  end

  def variations(opts) do
    [
      %Variation{
        id: :default,
        slots: [header(), main("default", opts), footer("default", opts)]
      },
      %Variation{
        id: :without_header,
        slots: [main("without-header", opts), footer("without-header", opts)]
      },
      %Variation{
        id: :without_footer,
        slots: [header(), main("without-footer", opts)]
      },
      %Variation{
        id: :with_header_and_footer,
        slots: [header(), footer("footer-only", opts)]
      }
    ]
  end

  def modifier_variation_base(id, _name, _value, opts) do
    %{slots: [header(), main(id, opts), footer(id, opts)]}
  end

  defp header do
    """
    <:header>
      <Phoenix.Component.link navigate="/">Pet Clinic</Phoenix.Component.link>
    </:header>
    """
  end

  defp main(id, opts) do
    nav = opts[:dependent_components][:vertical_nav]
    nested = opts[:dependent_components][:vertical_nav_nested]
    section = opts[:dependent_components][:vertical_nav_section]

    if nav && nested && section do
      """
      <:main>
        <.#{nav} id="#{id}-main-nav" label="Main">
          <:item>
            <Phoenix.Component.link navigate="/dashboard">
              Dashboard
            </Phoenix.Component.link>
          </:item>
          <:item>
            <.#{nested} id="#{id}-main-nav-content">
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
            </.#{nested}>
          </:item>
        </.#{nav}>
        <.#{section} id="#{id}-search">
          <:title>Search</:title>
          <:item><input type="search" placeholder="Search" aria-label="Search" /></:item>
        </.#{section}>
      </:main>
      """
    else
      """
      <:main>
        <p>
          Compile the vertical navigation components for a complete preview.
        </p>
      </:main>
      """
    end
  end

  defp footer(id, opts) do
    nav = opts[:dependent_components][:vertical_nav]

    if nav do
      """
      <:footer>
        <.#{nav} id="#{id}-user-menu" label="User menu">
          <:item>
            <Phoenix.Component.link navigate="/settings">
              Settings
            </Phoenix.Component.link>
          </:item>
          <:item>
            <Phoenix.Component.link navigate="/logout">
              Logout
            </Phoenix.Component.link>
          </:item>
        </.#{nav}>
      </:footer>
      """
    else
      "<:footer>Footer</:footer>"
    end
  end
end
