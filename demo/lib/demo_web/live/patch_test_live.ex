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
    {:ok,
     assign(socket,
       tick: 0,
       auto: false,
       inside: true,
       wrap: false,
       resend: 0,
       slides: [1, 2, 3]
     )}
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

  def handle_event("toggle_wrap", _params, socket) do
    {:noreply, assign(socket, :wrap, not socket.assigns.wrap)}
  end

  def handle_event("resend", _params, socket) do
    {:noreply, update(socket, :resend, &(&1 + 1))}
  end

  def handle_event("add_slide", _params, socket) do
    {:noreply, update(socket, :slides, &(&1 ++ [length(&1) + 1]))}
  end

  def handle_event("remove_slide", _params, socket) do
    {:noreply, update(socket, :slides, &Enum.drop(&1, -1))}
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
        <strong>Wrap in a comprehension:</strong>
        Renders the components inside a <code>:for</code>
        in order to re-send
        attributes to the component.
      </p>

      <p>
        <strong>Re-send:</strong> Changes the comprehension list without changing
        anything the components render.
      </p>

      <p>
        <strong>Add and remove slides:</strong>
        Changes the number of items a component renders, so that controls
        generated per item are added and removed by a patch.
      </p>

      <p>
        Tick <strong id="tick">{@tick}</strong>
        · auto {@auto} · tick inside
        components {@inside} · wrapped {@wrap} · re-sends {@resend} · slides {length(
          @slides
        )}
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
        <CoreComponents.button id="toggle-wrap" phx-click="toggle_wrap">
          {if @wrap, do: "Unwrap", else: "Wrap in a comprehension"}
        </CoreComponents.button>
        <CoreComponents.button id="resend" phx-click="resend" disabled={not @wrap}>
          Re-send
        </CoreComponents.button>
        <CoreComponents.button id="add-slide" phx-click="add_slide">
          Add slide
        </CoreComponents.button>
        <CoreComponents.button
          id="remove-slide"
          phx-click="remove_slide"
          disabled={length(@slides) <= 1}
        >
          Remove slide
        </CoreComponents.button>
      </CoreComponents.cluster>

      <div :for={_ <- wrap_list(@wrap, @resend)}>
        <.components tick={@tick} inside={@inside} slides={@slides} />
      </div>
      <.components :if={not @wrap} tick={@tick} inside={@inside} slides={@slides} />
    </CoreComponents.stack>
    """
  end

  # An empty list renders the unwrapped branch instead. The counter is the
  # element rather than the length, so that a re-send changes the comprehension
  # without adding or removing DOM nodes.
  defp wrap_list(true, resend), do: [resend]
  defp wrap_list(false, _resend), do: []

  attr :tick, :integer, required: true
  attr :inside, :boolean, required: true
  attr :slides, :list, required: true

  defp components(assigns) do
    ~H"""
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
        <CoreComponents.button phx-click="resend">Re-send from inside</CoreComponents.button>
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
        <CoreComponents.button phx-click="resend">Re-send from inside</CoreComponents.button>
        <CoreComponents.button phx-click={Doggo.hide_modal("test-alert-dialog")}>
          Close
        </CoreComponents.button>
      </:footer>
    </CoreComponents.alert_dialog>

    <h2>carousel</h2>
    <p>
      Add or remove a slide, then use the control that appeared and check that
      the active slide is still marked. The controls are generated per item, so
      a patch replaces them.
    </p>
    <CoreComponents.carousel id="test-carousel" label="Patch test" pagination>
      <:pause label="Pause slide show" resume_label="Resume slide show">
        <span>Pause</span>
        <span>Resume</span>
      </:pause>
      <:previous label="Previous Slide">Previous</:previous>
      <:next label="Next Slide">Next</:next>
      <:item :for={slide <- @slides} label={"Slide #{slide}"}>
        <p>Slide {slide}</p>
        <p :if={@inside}>Tick inside slide {slide}: {@tick}</p>
      </:item>
    </CoreComponents.carousel>

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
    """
  end
end
