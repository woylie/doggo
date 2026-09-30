defmodule Doggo.Storybook.Callout do
  @moduledoc false

  import Doggo.Storybook.Shared
  alias PhoenixStorybook.Stories.Variation

  def dependent_components, do: [:icon, :button]

  def template do
    """
    <div style="inline-size: 100%">
      <.psb-variation/>
    </div>
    """
  end

  def variations(opts) do
    dependent_components = opts[:dependent_components]

    [
      %Variation{
        id: :default,
        slots: [
          "<p>Keep your dog hydrated during long walks by bringing along a portable water bowl.</p>"
        ]
      },
      %Variation{
        id: :with_icon,
        slots: [
          "<p>Chewing on a bone can help keep your dog's teeth clean and strong.</p>",
          "<:icon>#{icon(:info, dependent_components)}</:icon>"
        ]
      },
      %Variation{
        id: :with_title,
        attributes: %{},
        slots: [
          "<:title>Dog Care Tip</:title>",
          "<p>Regular exercise is essential for keeping your dog healthy and happy.</p>"
        ]
      },
      %Variation{
        id: :with_title_and_icon,
        attributes: %{},
        slots: [
          "<:title>Fun Dog Fact</:title>",
          """
          <p>
            Did you know? Dogs have a sense of time and can get upset when their
            routine is changed.
          </p>
          """,
          "<:icon>#{icon(:info, dependent_components)}</:icon>"
        ]
      },
      %Variation{
        id: :with_action,
        attributes: %{},
        slots: [
          "<:title>Fun Dog Fact</:title>",
          """
          <p>
            Did you know? Dogs have a sense of time and can get upset when their
            routine is changed.
          </p>
          """,
          "<:action>#{button("Learn More", ~s|type="button"|, dependent_components)}</:action>"
        ]
      }
    ]
  end

  def modifier_variation_base(_id, _name, _value, _opts) do
    %{
      attributes: %{},
      slots: [
        "<:title>Dog Care Tip</:title>",
        "<p>Regular exercise is essential for keeping your dog healthy and happy.</p>"
      ]
    }
  end
end
