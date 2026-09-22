defmodule Storybook.Examples.ComboboxServerFiltering do
  use PhoenixStorybook.Story, :example

  alias DemoWeb.CoreComponents

  @breeds [
    {"Australian Shepherd", "australian_shepherd"},
    {"Beagle", "beagle"},
    {"Bernese Mountain Dog", "bernese_mountain_dog"},
    {"Border Collie", "border_collie"},
    {"Boxer", "boxer"},
    {"Bulldog", "bulldog"},
    {"Chihuahua", "chihuahua"},
    {"Dachshund", "dachshund"},
    {"Dalmatian", "dalmatian"},
    {"French Bulldog", "french_bulldog"},
    {"German Shepherd", "german_shepherd"},
    {"Golden Retriever", "golden_retriever"},
    {"Great Dane", "great_dane"},
    {"Labrador Retriever", "labrador_retriever"},
    {"Poodle", "poodle"},
    {"Pug", "pug"},
    {"Rottweiler", "rottweiler"},
    {"Shiba Inu", "shiba_inu"},
    {"Siberian Husky", "siberian_husky"},
    {"Whippet", "whippet"}
  ]

  @limit 5

  def doc do
    """
    This example illustrates server-side filtering in the combobox component.
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       breed: nil,
       display_value: nil,
       options: suggest(""),
       searches: 0
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container stack">
      <form phx-change="validate">
        <label for="breed-selector">Breed</label>
        <CoreComponents.combobox
          id="breed-selector"
          name="breed"
          list_label="Dog breeds"
          options={@options}
          value={@breed}
          display_value={@display_value}
          on_search="suggest"
        />
      </form>

      <CoreComponents.property_list>
        <:prop label="Submitted value">{@breed || "-"}</:prop>
        <:prop label="Options sent">
          {@options |> Enum.map(&elem(&1, 0)) |> Enum.join(", ")}
        </:prop>
        <:prop label="Searches handled">{@searches}</:prop>
      </CoreComponents.property_list>
    </div>
    """
  end

  @impl true
  def handle_event("suggest", %{"breed_search" => term}, socket) do
    {:noreply,
     socket
     |> assign(:options, suggest(term))
     |> update(:searches, &(&1 + 1))}
  end

  def handle_event("validate", %{"breed" => value}, socket) do
    {:noreply, assign(socket, breed: value, display_value: label(value))}
  end

  defp suggest(term) do
    needle = String.downcase(term)

    @breeds
    |> Enum.filter(fn {label, _} ->
      String.contains?(String.downcase(label), needle)
    end)
    |> Enum.take(@limit)
  end

  defp label(""), do: nil

  defp label(value) do
    Enum.find_value(@breeds, fn
      {label, ^value} -> label
      _ -> nil
    end)
  end
end
