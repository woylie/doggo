if Code.ensure_loaded?(PhoenixStorybook.Story) do
  defmodule Doggo.Storybook.PageHeader do
    @moduledoc false

    import Doggo.Storybook.Shared
    alias PhoenixStorybook.Stories.Variation

    def dependent_components, do: [:button_link]

    def layout, do: :one_column

    def template do
      """
      <div style="inline-size: 100%">
        <.psb-variation/>
      </div>
      """
    end

    def variations(opts) do
      [
        %Variation{
          id: :default,
          attributes: %{subtitle: "Share Your Pup's Story"},
          slots: [
            "<:title>Puppy Profiles</:title>",
            action(opts, "/puppies/new", "Add New Profile")
          ]
        },
        %Variation{
          id: :with_navigation,
          attributes: %{subtitle: "Share Your Pup's Story"},
          slots: [
            "<:title>Puppy Profiles</:title>",
            navigation(),
            action(opts, "/puppies/1/edit", "Edit Profile")
          ]
        },
        %Variation{
          id: :without_subtitle,
          attributes: %{},
          slots: [
            "<:title>Puppy Profiles</:title>",
            action(opts, "/puppies/new", "Add New Profile")
          ]
        },
        %Variation{
          id: :without_actions,
          attributes: %{subtitle: "Share Your Pup's Story"},
          slots: ["<:title>Puppy Profiles</:title>"]
        },
        %Variation{
          id: :title_only,
          attributes: %{},
          slots: ["<:title>Puppy Profiles</:title>"]
        },
        %Variation{
          id: :several_actions,
          attributes: %{subtitle: "Share Your Pup's Story"},
          slots: [
            "<:title>Puppy Profiles</:title>",
            action(opts, "/puppies/1/edit", "Edit Profile"),
            action(opts, "/puppies/new", "Add New Profile")
          ]
        }
      ]
    end

    def modifier_variation_base(_id, _name, _value, opts) do
      %{
        attributes: %{subtitle: "Share Your Pup's Story"},
        slots: [
          "<:title>Puppy Profiles</:title>",
          action(opts, "/puppies/new", "Add New Profile")
        ]
      }
    end

    defp navigation do
      """
      <:navigation navigate="/puppies">
        Back to puppy list
      </:navigation>
      """
    end

    defp action(opts, url, text) do
      """
      <:action>
        #{patch_link(url, text, opts[:dependent_components])}
      </:action>
      """
    end
  end
end
