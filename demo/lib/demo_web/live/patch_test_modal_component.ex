defmodule DemoWeb.PatchTestModalInComponent do
  @moduledoc """
  A modal rendered by a LiveComponent, for `DemoWeb.PatchTestLive`.
  """

  use DemoWeb, :live_component

  alias DemoWeb.CoreComponents

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <CoreComponents.modal id="test-modal-in-component">
        <:title>In a live component</:title>
        <p>Toggle the note and see whether this stays a modal.</p>
        <:footer>
          <CoreComponents.button id="toggle-note" phx-click="toggle_note">
            Toggle the note from inside
          </CoreComponents.button>
          <CoreComponents.button phx-click={
            Doggo.JS.hide_modal("test-modal-in-component")
          }>
            Close
          </CoreComponents.button>
        </:footer>
      </CoreComponents.modal>
    </div>
    """
  end
end
