defmodule Doggo.Storybook.AlertDialog do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def template do
    """
    <div>
      <button phx-click={Doggo.show_modal("alert-dialog-single-default")}>Open modal</button>
      <.psb-variation/>
    </div>
    """
  end

  def variations(_opts) do
    [
      %Variation{
        id: :default,
        attributes: %{id: "dog-alert-default"},
        slots: slots()
      }
    ]
  end

  def modifier_variation_base(_id, _name, _value, _opts) do
    %{
      slots: slots()
    }
  end

  defp slots do
    [
      """
      <:title>End Training Session Early?</:title>
      """,
      """
      <p>
        Are you sure you want to end the current training session with Bella?
        She's making great progress today!
      </p>
      """,
      """
      <:footer>
        <button
          phx-click={Phoenix.LiveView.JS.exec("data-cancel", to: "#alert-dialog-single-default")}
        >
          Yes, end session
        </button>
        <button
          phx-click={Phoenix.LiveView.JS.exec("data-cancel", to: "#alert-dialog-single-default")}
        >
          No, continue training
        </button>
      </:footer>
      """
    ]
  end
end
