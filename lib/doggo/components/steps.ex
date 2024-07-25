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
      extra: [
        current_class: "is-current",
        completed_class: "is-completed",
        upcoming_class: "is-upcoming",
        visually_hidden_class: "is-visually-hidden"
      ]
    ]
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
  def init_block(_opts, extra) do
    current_class = Keyword.fetch!(extra, :current_class)
    completed_class = Keyword.fetch!(extra, :completed_class)
    upcoming_class = Keyword.fetch!(extra, :upcoming_class)
    visually_hidden_class = Keyword.fetch!(extra, :visually_hidden_class)

    quote do
      var!(assigns) =
        assign(var!(assigns),
          current_class: unquote(current_class),
          completed_class: unquote(completed_class),
          upcoming_class: unquote(upcoming_class),
          visually_hidden_class: unquote(visually_hidden_class)
        )
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <nav aria-label={@label} class={@class} {@rest}>
      <ol>
        <.step
          :for={{step, index} <- Enum.with_index(@step)}
          step={step}
          index={index}
          current_step={@current_step}
          current_class={@current_class}
          completed_class={@completed_class}
          upcoming_class={@upcoming_class}
          visually_hidden_class={@visually_hidden_class}
          completed_label={@completed_label}
          linear={@linear}
        />
      </ol>
    </nav>
    """
  end

  defp step(
         %{
           index: index,
           current_step: current_step,
           current_class: current_class,
           completed_class: completed_class,
           upcoming_class: upcoming_class
         } = assigns
       ) do
    class =
      cond do
        index == current_step -> current_class
        index < current_step -> completed_class
        index > current_step -> upcoming_class
      end

    assigns =
      assign(assigns,
        class: class,
        current_class: nil,
        completed_class: nil,
        upcoming_class: nil
      )

    ~H"""
    <li class={@class} aria-current={@index == @current_step && "step"}>
      <span :if={@index < @current_step} class={@visually_hidden_class}>
        <%= @completed_label %>
      </span>
      <%= if @step[:on_click] && ((@linear && @index < @current_step) || (!@linear && @index != @current_step)) do %>
        <.link phx-click={@step[:on_click]}>
          <%= render_slot(@step) %>
        </.link>
      <% else %>
        <span><%= render_slot(@step) %></span>
      <% end %>
    </li>
    """
  end
end
