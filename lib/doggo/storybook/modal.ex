defmodule Doggo.Storybook.Modal do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def template do
    """
    <div>
      <button phx-click={Doggo.show_modal("modal-single-default")}>Open modal</button>
      <.psb-variation/>
    </div>
    """
  end

  def variations(_opts) do
    [
      %Variation{
        id: :default,
        attributes: %{id: "pet-modal"},
        slots: slots()
      }
    ]
  end

  def modifier_variation_base(id, _name, _value, _opts) do
    %{
      attributes: %{id: id},
      slots: slots()
    }
  end

  defp slots do
    [
      """
      <:title>Show pet</:title>
      """,
      """
      <p>My pet is called Johnny.</p>
      """,
      """
      <:footer>
        <Doggo.button phx-click={JS.exec("data-cancel", to: "#modal-single-default")}>
          Close
        </Doggo.button>
      </:footer>
      """
    ]
  end
end
