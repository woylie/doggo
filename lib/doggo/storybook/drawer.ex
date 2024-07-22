defmodule Doggo.Storybook.Drawer do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def variations do
    [
      %Variation{
        id: :default,
        slots: slots()
      }
    ]
  end

  def modifier_variation_base(_id, _name, _value) do
    %{
      slots: slots()
    }
  end

  defp slots do
    [
      """
      <:header>
        <Phoenix.Component.link navigate="/">
          Pet Clinic
        </Phoenix.Component.link>
      </:header>
      """,
      """
      <:main>
        Main
      </:main>
      """,
      """
      <:footer>
        Footer
      </:footer>
      """
    ]
  end

  # defp slots do
  #   [
  #     """
  #     <:header>
  #       <Phoenix.Component.link navigate="/">
  #         Pet Clinic
  #       </Phoenix.Component.link>
  #     </:header>
  #     """,
  #     """
  #     <:main>
  #       <Doggo.vertical_nav id="main-nav" label="Main">
  #         <:item>
  #           <Phoenix.Component.link navigate="/dashboard">
  #             Dashboard
  #           </Phoenix.Component.link>
  #         </:item>
  #         <:item>
  #           <Doggo.vertical_nav_nested id="main-nav-content">
  #             <:title>Content</:title>
  #             <:item current_page>
  #               <Phoenix.Component.link navigate="/posts">
  #                 Posts
  #               </Phoenix.Component.link>
  #             </:item>
  #             <:item>
  #               <Phoenix.Component.link navigate="/comments">
  #                 Comments
  #               </Phoenix.Component.link>
  #             </:item>
  #           </Doggo.vertical_nav_nested>
  #         </:item>
  #       </Doggo.vertical_nav>
  #       <Doggo.vertical_nav_section id="drawer-search">
  #         <:title>Search</:title>
  #         <:item><input type="search" placeholder="Search" /></:item>
  #       </Doggo.vertical_nav_section>
  #     </:main>
  #     """,
  #     """
  #     <:footer>
  #       <Doggo.vertical_nav id="user-menu" label="User menu">
  #         <:item>
  #           <Phoenix.Component.link navigate="/settings">
  #             Settings
  #           </Phoenix.Component.link>
  #         </:item>
  #         <:item>
  #           <Phoenix.Component.link navigate="/logout">
  #             Logout
  #           </Phoenix.Component.link>
  #         </:item>
  #       </Doggo.vertical_nav>
  #     </:footer>
  #     """
  #   ]
  # end
end
