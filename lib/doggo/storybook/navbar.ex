defmodule Doggo.Storybook.Navbar do
  @moduledoc false

  alias PhoenixStorybook.Stories.Variation

  def dependent_components, do: [:navbar_items]

  def variations(opts) do
    [
      %Variation{
        id: :default,
        attributes: %{label: "Main"},
        slots: slots_default(opts)
      },
      %Variation{
        id: :multiple_navigation_sections,
        attributes: %{label: "Main"},
        slots: slots_multi(opts)
      }
    ]
  end

  def modifier_variation_base(_id, _name, _value, opts) do
    %{
      attributes: %{label: "Main"},
      slots: slots_default(opts)
    }
  end

  defp slots_default(opts) do
    dependent_components = opts[:dependent_components]
    items_fun = dependent_components[:navbar_items]

    items =
      if items_fun do
        """
        <.#{items_fun}>
          <:item>
            <Phoenix.Component.link navigate="/about">
              About
            </Phoenix.Component.link>
          </:item>
          <:item>
            <Phoenix.Component.link navigate="/services">
              services
            </Phoenix.Component.link>
          </:item>
          <:item>
            <Phoenix.Component.link navigate="/login">
              Log in
            </Phoenix.Component.link>
          </:item>
        </.#{items_fun}>
        """
      else
        """
        <p>Please compile the <code>navbar_items</code> component for a complete preview.</p>
        """
      end

    [
      """
      <:brand>
        <Phoenix.Component.link navigate="/">
          Pet Clinic
        </Phoenix.Component.link>
      </:brand>
      """,
      items
    ]
  end

  defp slots_multi(opts) do
    dependent_components = opts[:dependent_components]
    items_fun = dependent_components[:navbar_items]

    items =
      if items_fun do
        """
        <.#{items_fun}>
          <:item>
            <Phoenix.Component.link navigate="/about">
              About
            </Phoenix.Component.link>
          </:item>
          <:item>
            <Phoenix.Component.link navigate="/services">
              services
            </Phoenix.Component.link>
          </:item>
        </.#{items_fun}>
        <.#{items_fun}>
          <:item>
            <Phoenix.Component.link navigate="/login">
              Log in
            </Phoenix.Component.link>
          </:item>
        </.#{items_fun}>
        """
      else
        """
        <p>Please compile the <code>navbar_items</code> component for a complete preview.</p>
        """
      end

    [
      """
      <:brand>
        <Phoenix.Component.link navigate="/">
          Pet Clinic
        </Phoenix.Component.link>
      </:brand>
      """,
      items
    ]
  end
end
