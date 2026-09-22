defmodule Doggo.Storybook.Modal do
  @moduledoc false

  import Doggo.Storybook.Shared

  alias PhoenixStorybook.Stories.Variation

  def dependent_components, do: [:button]

  def template(opts) do
    """
    <div>
      #{button("Open modal", ~s|type="button" phx-click={Doggo.show_modal(":variation_id")}|, opts[:dependent_components])}
      <.psb-variation/>
    </div>
    """
  end

  def variations(opts) do
    [
      %Variation{
        id: :default,
        note:
          "`Doggo.show_modal/1` opens the dialog, which works on every " <>
            "browser and needs the hook. The close button in the footer uses " <>
            "`JS.exec(\"data-cancel\")`.",
        attributes: %{id: "dog-modal-default"},
        slots: slots("modal-single-default", opts)
      },
      %Variation{
        id: :without_javascript,
        note:
          "The button has `command` and `commandfor` attributes, " <>
            "which are part of the Invoker Commands API. This works with only " <>
            "HTML attributes without any JavaScript. " <>
            "If the browser doesn't support it, the hook fills the functionality.",
        template: command_template(opts),
        attributes: %{id: "dog-modal-declarative"},
        slots: slots("modal-single-without-javascript", opts)
      },
      %Variation{
        id: :long_content,
        attributes: %{id: "dog-modal-long"},
        slots: long_slots("modal-single-long-content", opts)
      },
      %Variation{
        id: :close_icon,
        note:
          "The `:close` slot replaces the label text of the close button with " <>
            "other content, usually an icon. `close_label` still gives the " <>
            "button its accessible name.",
        attributes: %{id: "dog-modal-close-icon", close_label: "Close"},
        slots: close_icon_slots("modal-single-close-icon", opts)
      },
      %Variation{
        id: :not_dismissable,
        note:
          "`dismissable={false}` renders `closedby=\"none\"` and no close " <>
            "button, so neither `Esc` nor a click outside closes it. The " <>
            "control in the footer is the only way out.",
        attributes: %{id: "dog-modal-not-dismissable", dismissable: false},
        slots: slots("modal-single-not-dismissable", opts)
      }
    ]
  end

  defp command_template(opts) do
    """
    <div>
      #{button("Open modal", ~s|type="button" command="show-modal" commandfor=":variation_id"|, opts[:dependent_components])}
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
      slots: slots("modal-#{name}-dog-mod-var-#{name}-#{value}", opts)
    }
  end

  defp close_icon_slots(id, opts) do
    icon = icon(:close, opts[:dependent_components])
    slots(id, opts) ++ ["<:close>#{icon}</:close>"]
  end

  defp long_slots(id, opts) do
    [title | rest] = slots(id, opts, "")

    paragraphs =
      Enum.map_join(1..20, "\n", fn i ->
        attrs = if i == 1, do: ~s| tabindex="-1" autofocus|, else: ""

        "<p#{attrs}>Johnny was rehomed in #{2010 + i}. He is house trained, walks " <>
          "well on a lead, and is happiest with a garden and someone at " <>
          "home during the day. He does not get on with cats.</p>"
      end)

    [title, paragraphs | tl(rest)]
  end

  defp slots(id, opts, close_attrs \\ " autofocus") do
    dependent_components = opts[:dependent_components]

    tag_name =
      if function_name = dependent_components[:button] do
        ".#{function_name}"
      else
        "button"
      end

    [
      """
      <:title>Show pet</:title>
      """,
      """
      <p>My pet is called Johnny.</p>
      """,
      """
      <:footer>
        <#{tag_name}#{close_attrs} phx-click={JS.exec("data-cancel", to: "##{id}")}>
          Close
        </#{tag_name}>
      </:footer>
      """
    ]
  end
end
