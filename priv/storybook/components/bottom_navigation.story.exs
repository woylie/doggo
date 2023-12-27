defmodule Storybook.Components.BottomNavigation do
  use PhoenixStorybook.Story, :component

  def function, do: &Doggo.bottom_navigation/1

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          current_value: Profile
        },
        slots: items()
      },
      %Variation{
        id: :hidden_labels,
        attributes: %{
          current_value: Profile,
          hide_labels: true
        },
        slots: items()
      }
    ]
  end

  defp items do
    [
      """
      <:item label="Profile" navigate="/profile" value={Profile}>
        #{user_icon()}
      </:item>
      """,
      """
      <:item label="Appointments" navigate="/appointments" value={Appointments}>
        #{calendar_icon()}
      </:item>
      """,
      """
      <:item label="Messages" navigate="/messages" value={Messages}>
        #{mails_icon()}
      </:item>
      """
    ]
  end

  defp user_icon do
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
      class="lucide lucide-user"
    >
      <path d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2" /><circle
        cx="12"
        cy="7"
        r="4"
      />
    </svg>
    """
  end

  defp calendar_icon do
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
      class="lucide lucide-calendar-days"
    >
      <rect width="18" height="18" x="3" y="4" rx="2" ry="2" /><line
        x1="16"
        x2="16"
        y1="2"
        y2="6"
      /><line x1="8" x2="8" y1="2" y2="6" /><line x1="3" x2="21" y1="10" y2="10" /><path d="M8 14h.01" /><path d="M12 14h.01" /><path d="M16 14h.01" /><path d="M8 18h.01" /><path d="M12 18h.01" /><path d="M16 18h.01" />
    </svg>
    """
  end

  defp mails_icon do
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
      class="lucide lucide-mails"
    >
      <rect width="16" height="13" x="6" y="4" rx="2" /><path d="m22 7-7.1 3.78c-.57.3-1.23.3-1.8 0L6 7" /><path d="M2 8v11c0 1.1.9 2 2 2h14" />
    </svg>
    """
  end
end
