defmodule Storybook.Components.AlertDialog do
  use PhoenixStorybook.Story, :component

  def function, do: &Doggo.alert_dialog/1

  def template do
    """
    <div>
      <button phx-click={Doggo.show_modal("alert-dialog-single-default")}>Open modal</button>
      <.psb-variation/>
    </div>
    """
  end

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{id: "dog-alert"},
        slots: [
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
            <Doggo.button
              variant={:primary}
              phx-click={JS.exec("data-cancel", to: "#alert-dialog-single-default")}
            >
              Yes, end session
            </Doggo.button>
            <Doggo.button
              variant={:secondary}
              phx-click={JS.exec("data-cancel", to: "#alert-dialog-single-default")}
            >
              No, continue training
            </Doggo.button>
          </:footer>
          """
        ]
      }
    ]
  end
end
