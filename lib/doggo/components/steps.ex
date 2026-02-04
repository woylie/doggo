defmodule Doggo.Components.Steps do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    Renders a navigation for form steps.
    """
  end

  @impl true
  def builder_doc do
    """
    - `:current_class` - This class is added to the current step.
    - `:completed_class` - This class is added to previous steps.
    - `:upcoming_class` - This class is added to upcoming steps.
    - `:visually_hidden_class` - This class is used to visually hide the
      accessibility text added to completed steps.
    """
  end

  @impl true
  def usage do
    """
    With patch navigation:

    ```heex
    <.steps current_step={0}>
      <:step on_click={JS.patch(to: ~p"/form/step/personal-information")}>
        Profile
      </:step>
      <:step on_click={JS.patch(to: ~p"/form/step/delivery")}>
        Delivery
      </:step>
      <:step on_click={JS.patch(to: ~p"/form/step/confirmation")}>
        Confirmation
      </:step>
    </.steps>
    ```

    With push events:

    ```heex
    <.steps current_step={0}>
      <:step on_click={JS.push("go-to-step", value: %{step: "profile"})}>
        Profile
      </:step>
      <:step on_click={JS.push("go-to-step", value: %{step: "delivery"})}>
        Delivery
      </:step>
      <:step on_click={JS.push("go-to-step", value: %{step: "confirmation"})}>
        Confirmation
      </:step>
    </.steps>
    ```
    """
  end

  @impl true
  def config do
    [
      type: :navigation,
      since: "0.6.0",
      maturity: :developing,
      modifiers: [],
      data_attrs: ["data-state", "data-visually-hidden"]
    ]
  end

  @impl true
  def nested_classes(_) do
    []
  end

  @impl true
  def attrs_and_slots do
    quote do
      attr :label, :string, default: "Form steps"

      attr :current_step, :integer,
        required: true,
        doc: """
        The current form step, zero-based index.
        """

      attr :completed_label, :string,
        default: "Completed: ",
        doc: """
        Visually hidden text that is rendered for screen readers for completed
        steps.
        """

      attr :linear, :boolean,
        default: false,
        doc: """
        If `true`, clickable links are only rendered for completed steps.

        If `false`, also upcoming steps are clickable.

        If you don't want any clickable links to be rendered, omit the `on_click`
        attribute on the `:step` slots.
        """

      attr :rest, :global, doc: "Any additional HTML attributes."

      slot :step, required: true do
        attr :on_click, :any,
          doc: """
          Event name or `Phoenix.LiveView.JS` command to execute when clicking on
          the step.
          """
      end
    end
  end

  @impl true
  def init_block(_opts, _extra) do
    []
  end

  @impl true
  def render(assigns) do
    ~H"""
    <nav aria-label={@label} class={@class} {@data_attrs} {@rest}>
      <ol>
        <.step
          :for={{step, index} <- Enum.with_index(@step)}
          step={step}
          index={index}
          current_step={@current_step}
          completed_label={@completed_label}
          linear={@linear}
        />
      </ol>
    </nav>
    """
  end

  defp step(%{index: index, current_step: current_step} = assigns) do
    state =
      cond do
        index == current_step -> "current"
        index < current_step -> "completed"
        index > current_step -> "upcoming"
      end

    assigns = assign(assigns, state: state)

    ~H"""
    <li data-state={@state} aria-current={@index == @current_step && "step"}>
      <span :if={@index < @current_step} data-visually-hidden>
        {@completed_label}
      </span>
      <%= if @step[:on_click] && ((@linear && @index < @current_step) || (!@linear && @index != @current_step)) do %>
        <.link phx-click={@step[:on_click]}>
          {render_slot(@step)}
        </.link>
      <% else %>
        <span>{render_slot(@step)}</span>
      <% end %>
    </li>
    """
  end
end
