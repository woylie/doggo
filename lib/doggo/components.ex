defmodule Doggo.Components do
  @moduledoc """
  This module defines macros that generate customized components.

  ## Usage

  Add `use Doggo.Components` to your module and ensure you also add
  `use Phoenix.Component`. Then use the macros in this module to generate the
  components you need.

  > #### `use Doggo.Components` {: .info}
  >
  > When you `use Doggo.Components`, the module will import `Doggo.Components`
  > and define a `__dog_components__/1` function that returns a map containing
  > the options of the Doggo components you used.

  To generate all components with their default options:

      defmodule MyAppWeb.CoreComponents do
        use Doggo.Components
        use Phoenix.Component

        build_accordion()
        build_action_bar()
        build_alert()
        build_alert_dialog()
        build_app_bar()
        build_avatar()
        build_badge()
        build_bottom_navigation()
        build_box()
        build_breadcrumb()
        build_button()
        build_button_link()
        build_callout()
        build_card()
        build_carousel()
        build_cluster()
        build_combobox()
        build_date()
        build_datetime()
        build_disclosure_button()
        build_drawer()
        build_fallback()
        build_field()
        build_field_group()
        build_frame()
        build_icon()
        build_icon_sprite()
        build_image()
        build_menu()
        build_menu_bar()
        build_menu_button()
        build_menu_group()
        build_menu_item()
        build_menu_item_checkbox()
        build_menu_item_radio_group()
        build_modal()
        build_navbar()
        build_navbar_items()
        build_page_header()
        build_property_list()
        build_radio_group()
        build_skeleton()
        build_split_pane()
        build_stack()
        build_steps()
        build_switch()
        build_tab_navigation()
        build_table()
        build_tabs()
        build_tag()
        build_time()
        build_toggle_button()
        build_toolbar()
        build_tooltip()
        build_tree()
        build_tree_item()
        build_vertical_nav()
        build_vertical_nav_nested()
        build_vertical_nav_section()
      end

  ## Common Options

  All component macros support the following options:

  - `name` - The name of the function of the generated component. Defaults to
    the macro name.
  - `base_class` - The base class used on the root element of the component. If
    not set, a default base class is used.
  - `modifiers` - A keyword list of modifier attributes. For each item, an
    attribute is added. The options will be passed to
    `Phoenix.Component.attr/3`. Most components define a set of default
    modifiers that can be overridden. Any attribute type is allowed, but since
    the value will be used as data attribute value, it needs to be possible to
    convert the value to a string. The `:type` option defaults to `:string`.

  Some components have additional options that are mostly used to allow the
  customization of certain class names or to set the Gettext module.
  """

  use Phoenix.Component

  import Doggo.Macros

  defmacro __using__(_opts \\ []) do
    quote do
      import Doggo.Components

      Module.register_attribute(__MODULE__, :dog_components, accumulate: true)

      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(env) do
    components =
      env.module
      |> Module.get_attribute(:dog_components)
      |> Map.new(fn info -> {info[:name], Keyword.delete(info, :name)} end)

    quote do
      def __dog_components__, do: unquote(Macro.escape(components))
    end
  end

  component(:accordion)
  component(:action_bar)
  component(:alert)
  component(:alert_dialog)
  component(:app_bar)
  component(:avatar)
  component(:badge)
  component(:bottom_navigation)
  component(:box)
  component(:breadcrumb)
  component(:button)
  component(:button_link)
  component(:callout)
  component(:card)
  component(:carousel)
  component(:cluster)
  component(:combobox)
  component(:date)
  component(:datetime)
  component(:disclosure_button)
  component(:drawer)
  component(:fallback)
  component(:field)
  component(:field_group)
  component(:frame)
  component(:icon)
  component(:icon_sprite)
  component(:image)
  component(:menu)
  component(:menu_bar)
  component(:menu_button)
  component(:menu_group)
  component(:menu_item)
  component(:menu_item_checkbox)
  component(:menu_item_radio_group)
  component(:modal)
  component(:navbar)
  component(:navbar_items)
  component(:page_header)
  component(:property_list)
  component(:radio_group)
  component(:skeleton)
  component(:split_pane)
  component(:stack)
  component(:steps)
  component(:switch)
  component(:tab_navigation)
  component(:table)
  component(:tabs)
  component(:tag)
  component(:time)
  component(:toggle_button)
  component(:toolbar)
  component(:tooltip)
  component(:tree)
  component(:tree_item)
  component(:vertical_nav)
  component(:vertical_nav_nested)
  component(:vertical_nav_section)
end
