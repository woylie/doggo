defmodule Storybook.Components.Callout do
  use PhoenixStorybook.Story, :component

  def function, do: &Doggo.callout/1

  def variations do
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
          "<:icon>#{icon()}</:icon>"
        ]
      },
      %Variation{
        id: :with_title,
        attributes: %{title: "Dog Care Tip"},
        slots: [
          "<p>Regular exercise is essential for keeping your dog healthy and happy.</p>"
        ]
      },
      %VariationGroup{
        id: :variants,
        variations:
          for variant <- Doggo.variants() do
            %Variation{
              id: variant,
              attributes: %{title: "Dog Care Tip", variant: variant},
              slots: [
                "<p>Regular exercise is essential for keeping your dog healthy and happy.</p>"
              ]
            }
          end
      },
      %Variation{
        id: :with_title_and_icon,
        attributes: %{title: "Fun Dog Fact"},
        slots: [
          """
          <p>
            Did you know? Dogs have a sense of time and can get upset when their
            routine is changed.
          </p>
          """,
          "<:icon>#{icon()}</:icon>"
        ]
      }
    ]
  end

  defp icon do
    """
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width="24"
      height="24"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      stroke-width="2"
      stroke-linecap="round"
      stroke-linejoin="round"
      class="lucide lucide-info"
    >
      <circle cx="12" cy="12" r="10"/><path d="M12 16v-4"/>
      <path d="M12 8h.01"/>
    </svg>
    """
  end
end
