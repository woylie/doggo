defmodule Storybook.Components.Modal do
  use PhoenixStorybook.Story, :component

  def function, do: &Doggo.modal/1

  def template do
    """
    <div>
      <button phx-click={Doggo.show_modal("modal-single-default")}>Open modal</button>
      <.lsb-variation/>
    </div>
    """
  end

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{id: "pet-modal"},
        slots: [
          """
          <:title>Show pet</:title>
          """,
          """
          <p>My pet is called Johnny.</p>
          """,
          """
          <:footer>
            <.link phx-click={JS.exec("data-cancel", to: "#modal-single-default")}>
              Close
            </.link>
          </:footer>
          """
        ]
      }
    ]
  end
end
