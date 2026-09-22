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
          "An alert dialog is not dismissable by default, so it renders " <>
            "`closedby=\"none\"` and no close button. Neither `Esc` nor a " <>
            "click outside closes it, which is the point: the answer has to " <>
            "come from the footer.",
        attributes: %{id: "dog-alert-default"},
        slots: slots("alert-dialog-single-default", opts)
      },
      %Variation{
        id: :dismissable,
        note:
          "`dismissable` adds the close button and `closedby=\"any\"`, so " <>
            "`Esc` and a click outside close it as well. Use it only when " <>
            "dismissing the dialog is itself a valid answer.",
        attributes: %{id: "dog-alert-dismissable", dismissable: true},
        slots: slots("alert-dialog-single-dismissable", opts)
      },
      %Variation{
        id: :close_icon,
        note:
          "The `:close` slot replaces the label text of the close button with " <>
            "other content, usually an icon. `close_label` still gives the " <>
            "button its accessible name.",
        attributes: %{
          id: "dog-alert-close-icon",
          dismissable: true,
          close_label: "Close"
        },
        slots: close_icon_slots("alert-dialog-single-close-icon", opts)
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

  defp close_icon_slots(id, opts) do
    icon = icon(:close, opts[:dependent_components])
    slots(id, opts) ++ ["<:close>#{icon}</:close>"]
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
        <#{tag_name} phx-click={JS.exec("data-cancel", to: "##{id}")}>
          Yes, end session
        </#{tag_name}>
        <#{tag_name} autofocus phx-click={JS.exec("data-cancel", to: "##{id}")}>
          No, continue training
        </#{tag_name}>
      </:footer>
      """
    ]
  end
end
