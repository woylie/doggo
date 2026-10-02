if Code.ensure_loaded?(PhoenixStorybook.Story) do
  defmodule Doggo.Storybook.AlertDialog do
    @moduledoc false

    import Doggo.Storybook.Shared

    alias PhoenixStorybook.Stories.Variation

    def dependent_components, do: [:button, :icon]

    def template(opts) do
      """
      <div>
        #{button("Open alert dialog", ~s|type="button" phx-click={Doggo.show_modal(":variation_id")}|, opts[:dependent_components])}
        <.psb-variation/>
      </div>
      """
    end

    def variations(opts) do
      [
        %Variation{
          id: :default,
          note:
            "An alert dialog defaults to `closedby=\"none\"`, which means " <>
              "that no close button is rendered and neither `Esc` nor a " <>
              "click outside closes it.",
          attributes: %{id: "dog-alert-default"},
          slots: slots("alert-dialog-single-default", opts)
        },
        %Variation{
          id: :closedby_any,
          note:
            "With `closedby=\"any\"`, a close button is rendered and the " <>
              "dialog can be closed with `Esc` and a click outside. Use it only " <>
              "when dismissing the dialog is itself a valid answer.",
          attributes: %{id: "dog-alert-closedby-any", closedby: "any"},
          slots: slots("alert-dialog-single-closedby-any", opts)
        },
        %Variation{
          id: :closedby_closerequest,
          note:
            "With `closedby=\"closerequest\"`, a close button is rendered and " <>
              "the dialog can be closed with `Esc`, but not with a click " <>
              "outside.",
          attributes: %{
            id: "dog-alert-closedby-closerequest",
            closedby: "closerequest"
          },
          slots: slots("alert-dialog-single-closedby-closerequest", opts)
        },
        %Variation{
          id: :without_javascript,
          note:
            "The button has `command` and `commandfor` attributes, " <>
              "which are part of the Invoker Commands API. This works with only " <>
              "HTML attributes without any JavaScript. " <>
              "If the browser doesn't support it, the hook fills the functionality.",
          template: command_template(opts),
          attributes: %{id: "dog-alert-declarative"},
          slots: slots("alert-dialog-single-without-javascript", opts)
        }
      ]
    end

    defp command_template(opts) do
      """
      <div>
        #{button("Open alert dialog", ~s|type="button" command="show-modal" commandfor=":variation_id"|, opts[:dependent_components])}
        <.psb-variation/>
      </div>
      """
    end

    def modifier_variation_group_template(_name, opts) do
      template(opts)
    end

    def modifier_variation_base(id, name, value, opts) do
      %{
        attributes: %{id: id},
        slots: slots("alert-dialog-#{name}-dog-mod-var-#{name}-#{value}", opts)
      }
    end

    defp slots(id, opts) do
      dependent_components = opts[:dependent_components]

      tag_name =
        if function_name = dependent_components[:button] do
          ".#{function_name}"
        else
          "button"
        end

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
          <#{tag_name} phx-click={Doggo.hide_modal("#{id}")}>
            Yes, end session
          </#{tag_name}>
          <#{tag_name} autofocus phx-click={Doggo.hide_modal("#{id}")}>
            No, continue training
          </#{tag_name}>
        </:footer>
        """
      ]
    end
  end
end
