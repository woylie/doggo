defmodule DemoWeb.PatchTestLive do
  @moduledoc """
  Harness for checking whether interactive components keep their state when
  LiveView patches the DOM.

  Interactive component stores its state in the DOM. This view exists to find
  out whether a patch resets the state.

  Mounted at `/patch-test`.
  """

  use DemoWeb, :live_view

  alias DemoWeb.CoreComponents

  @tick_interval 2000

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, tick: 0, auto: false, inside: true)}
  end

  @impl true
  def handle_event("bump", _params, socket) do
    {:noreply, update(socket, :tick, &(&1 + 1))}
  end

  def handle_event("toggle_auto", _params, socket) do
    auto = not socket.assigns.auto
    if auto, do: :timer.send_interval(@tick_interval, self(), :tick)
    {:noreply, assign(socket, :auto, auto)}
  end

  def handle_event("toggle_inside", _params, socket) do
    {:noreply, assign(socket, :inside, not socket.assigns.inside)}
  end

  def handle_event("noop", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info(:tick, socket) do
    if socket.assigns.auto do
      {:noreply, update(socket, :tick, &(&1 + 1))}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <CoreComponents.stack>
      <h1>LiveView patch test</h1>

      <ol>
        <li>Put a component into a non-initial state.</li>
        <li>Press <strong>Bump</strong> to force a re-render unrelated to it.</li>
        <li>Check whether the component reverted.</li>
      </ol>

      <p>
        <strong>Tick inside/outside components:</strong> Applies changes within
        the component's subtree or outside of it.
      </p>

      <p>
        <strong>Round trip:</strong> Sends an event that does not change
        assigns.
      </p>

      <p>
        Tick <strong id="tick">{@tick}</strong> · auto {@auto} · tick inside
        components {@inside}
      </p>

      <CoreComponents.cluster>
        <CoreComponents.button id="bump" phx-click="bump">Bump</CoreComponents.button>
        <CoreComponents.button id="toggle-auto" phx-click="toggle_auto">
          {if @auto, do: "Stop auto-tick", else: "Start auto-tick"}
        </CoreComponents.button>
        <CoreComponents.button id="toggle-inside" phx-click="toggle_inside">
          {if @inside, do: "Move tick outside", else: "Move tick inside"}
        </CoreComponents.button>
        <CoreComponents.button id="round-trip" phx-click="noop">Round trip</CoreComponents.button>
      </CoreComponents.cluster>

      <h2>modal</h2>
      <p>
        <code>modal</code>
        defaults to <code>dismissable</code>, so clicking
        outside it closes it. Use <strong>Bump from inside</strong>
        or start the auto-tick before opening.
      </p>
      <div>
        <CoreComponents.button phx-click={Doggo.show_modal("test-modal")}>
          Open modal
        </CoreComponents.button>
      </div>
      <CoreComponents.modal id="test-modal">
        <:title>Modal</:title>
        <p>Bump the tick and see whether this closes.</p>
        <p :if={@inside}>Tick inside the modal: {@tick}</p>
        <:footer>
          <CoreComponents.button phx-click="bump">Bump from inside</CoreComponents.button>
          <CoreComponents.button phx-click={Doggo.hide_modal("test-modal")}>
            Close
          </CoreComponents.button>
        </:footer>
      </CoreComponents.modal>

      <h2>alert_dialog</h2>
      <div>
        <CoreComponents.button phx-click={Doggo.show_modal("test-alert-dialog")}>
          Open alert dialog
        </CoreComponents.button>
      </div>
      <CoreComponents.alert_dialog id="test-alert-dialog">
        <:title>Alert dialog</:title>
        <p>Nothing focusable in here.</p>
        <p :if={@inside}>Tick inside the dialog: {@tick}</p>
        <:footer>
          <CoreComponents.button phx-click="bump">Bump from inside</CoreComponents.button>
          <CoreComponents.button phx-click={Doggo.hide_modal("test-alert-dialog")}>
            Close
          </CoreComponents.button>
        </:footer>
      </CoreComponents.alert_dialog>

      <h2>tabs</h2>
      <p>Select the second tab, then bump.</p>
      <CoreComponents.tabs id="test-tabs" label="Patch test">
        <:panel label="First">
          <p>First panel.</p>
          <p :if={@inside}>Tick inside panel one: {@tick}</p>
        </:panel>
        <:panel label="Second">
          <p>Second panel.</p>
          <p :if={@inside}>Tick inside panel two: {@tick}</p>
        </:panel>
      </CoreComponents.tabs>

      <h2>accordion</h2>
      <p>Collapse the first section, then bump.</p>
      <CoreComponents.accordion id="test-accordion">
        <:section title="Section one">
          <p>Some content.</p>
          <p :if={@inside}>Tick inside the section: {@tick}</p>
        </:section>
        <:section title="Section two">
          <p>Some other content.</p>
        </:section>
      </CoreComponents.accordion>

      <h2>disclosure_button</h2>
      <div>
        <CoreComponents.disclosure_button controls="test-disclosure">
          Toggle details
        </CoreComponents.disclosure_button>
      </div>
      <div id="test-disclosure" hidden>
        <p>Expand this, then bump.</p>
        <p :if={@inside}>Tick inside the disclosure: {@tick}</p>
      </div>

      <h2>toggle_button</h2>
      <div>
        <CoreComponents.toggle_button on_click={
          JS.toggle_attribute({"hidden", "hidden"}, to: "#toggle-on")
          |> JS.toggle_attribute({"hidden", "hidden"}, to: "#toggle-off")
        }>
          Toggle
        </CoreComponents.toggle_button>
      </div>
      <span id="toggle-on" hidden>pressed</span>
      <span id="toggle-off">not pressed</span>
      <p :if={@inside}>Tick next to the toggle: {@tick}</p>
    </CoreComponents.stack>
    """
  end
end
