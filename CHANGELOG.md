# Changelog

**Note:** You may need to force-compile your application when upgrading Doggo.

## Unreleased

**This release contains significant breaking changes. Check your component
styles carefully when upgrading.**

### Changed

- Rename `mix dog.classes` to `mix dog.safelist`.
- Rename `Doggo.classes/1` to `Doggo.safelist/1`.
- Include data attributes in `mix dog.safelist` and `Doggo.safelist/1` output.
- Support `:type` option in modifiers instead of requiring string attributes.
- Use `data-` attributes instead of classes for modifiers (see upgrade guide
  below).
- `button_link` component
  - Remove `disabled_class` option.
  - Use `data-disabled` attribute instead of the `disabled_class`
    (selector: `[data-disabled]`).
- `field` component
  - Remove `addon_left_class`, `addon_right_class`, and `visually_hidden_class`
    options.
  - Use `data-addon` attribute instead of `addon_left_class` and
    `addon_right_class` (selectors: `[data-addon~="left"]`,
    `[data-addon~="right"])`.
  - Use `data-visually-hidden` attribute instead of `visually_hidden_class`
    (selector: `[data-visually-hidden]`).
  - Use `data-invalid` attribute instead of `has-errors` class
    (selector: `[data-invalid]`).
  - Use `data-state` attribute instead of `{base_class}-switch-state-{on|off}`
    classes (selectors: `[data-state="on"]`, `[data-state="off"]`).
- `frame` and `image` component
  - Make `ratio` required for `frame` component.
  - Change format of `ratio` attribute (before: `16-by-9`, after: `16:9`).
  - Use `data-numerator` and `data-denominator` attributes instead of adding
    a class for the ratio (before: `class="is-16-by-9"`, after:
    `data-numerator="16" data-denominator="9"`).
- `icon` and `icon_sprite` component
  - Remove `text_position_after_class`, `text_position_before_class`,
    `text_position_hidden_class`, and `visually_hidden_class` options.
  - Use `data-text-position` class instead of `text_position_*` classes
    (selectors: `[data-text-position="before"]`,
    `[data-text-position="after"]`, `[data-text-position="hidden"]`).
  - Use `data-visually-hidden` attribute instead of `visually_hidden_class`
    (selector: `[data-visually-hidden]`).
- `stack` component
  - Remove `recursive_class` option.
  - Use `data-recursive` attribute instead of `recursive_class`
    (selector: `[data-recursive]`).
- `steps` component
  - Remove `current_class`, `completed_class`, `upcoming_class`, and
    `visually_hidden_class` options.
  - Use `data-visually-hidden` attribute instead of `visually_hidden_class`
    (selector: `[data-visually-hidden]`).
  - Use `data-state` attribute instead of `current_class`, `completed_class`,
    and `upcoming_class` (selectors: `[data-state="current"]`,
    `[data-state="completed"]`, `[data-state="upcoming"]`).

### Removed

- Remove `class_name_fun` option.
- Remove `Doggo.modifier_class_name/2`.

### Upgrade Guide

In previous versions, modifier attribute values would be reflected with CSS
classes in the HTML output.

For example, if you had a tag component with a `size` modifier like this:

```elixir
build_tag(
  modifiers: [
    size: [values: ["small", "medium", "large"], default: "medium"]
  ]
)
```

And you used it like:

```html
<.tag size="small">Hello</.tag>
```

This would result in the addition of an `is-small` class.

```html
<span class="tag is-small">Hello</span>
```

The implementation was changed to use separate data attributes for each modifier
instead. Now, the generated HTML will look like this:

```html
<span class="tag" data-size="small">Hello</span>
```

In your CSS styles, you will need to change the selectors accordingly.

Before:

```css
.tag.is-small {
}
```

After:

```css
.tag[data-size="small"] {
}
```

## [0.12.0] - 2026-01-15

### Changed

- Breaking: The icon component renders the inner SVG with a referenced icon
  module now instead of using an inner block.
- Add `navigation` slot to `page_header` component.

## [0.11.0] - 2025-12-16

### Added

- Add `--check` switch to `mix dog.classes`.

### Changed

- Require `phoenix_live_view` `~> 1.1.0` and `phoenix_storybook` `~> 0.9`.

## [0.10.8] - 2025-09-15

### Changed

- Support `gettext` `~> 1.0`.

## [0.10.7] - 2025-07-31

### Changed

- Require `phoenix_live_view` `~> 1.0.6 or ~> 1.1.0`.

## [0.10.6] - 2025-07-08

### Changed

- Loosen version requirement for `phoenix_storybook`.

## [0.10.5] - 2025-06-10

### Fixed

- Add `required` attribute to radio inputs.

## [0.10.4] - 2025-02-22

### Fixed

- Escape select option values in `field` component.

## [0.10.3] - 2025-02-11

### Changed

- Build select options with function components instead of
  `Phoenix.HTML.Form.options_for_select/2`.

## [0.10.2] - 2025-01-08

### Changed

- Require Phoenix LiveView ~> 1.0.0.
- Support Phoenix Storybook 0.8.

## [0.10.1] - 2024-11-20

### Changed

- Support Phoenix Storybook 0.7.x.

## [0.10.0] - 2024-11-19

### Changed

- `field` component:
  - Remove `required_text` attribute in favor of a compile-time option passed to
    `build_field/1`.
  - Remove `required_title` attribute; remove `title` from `span` element.
  - Change default for `required_text` from `*` to `(required)`.
  - Translate `required_text` with Gettext module, if set.
  - Add `optional_text` option to `build_field/1` to mark optional fields with
    a label suffix. Defaults to `nil`.
  - Prefix `checkbox`, `checkbox-group`, `radio-group`, `required-mark`,
    `select`, `switch`, `switch-label`, `switch-state`, `switch-state-off`, and
    `switch-state-on` classes with base class for consistency.

## [0.9.1] - 2024-10-18

### Changed

- Add header to file output of `mix dog.classes`.

### Fixed

- Fix deprecation warning in Phoenix LiveView 1.0.7-rc.7.

## [0.9.0] - 2024-09-25

### Changed

- Rename `Doggo.modifier_classes/1` to `Doggo.classes/1` and `mix dog.modifiers`
  to `mix dog.classes`. The function and mix task return all base classes,
  nested classes, and additional customizable classes in addition to the
  modifier classes now.
- Wrap inner block of `box` component into `div`.
- Add example styles for box and tag components.

### Removed

- The `fab` component was removed. It might have made sense to have it as a
  separate component before components could be customized, but since the
  semantics are the same as a regular button, you can just make one with
  `build_button(name: :fab, base_class: "fab")` if you need it.

## [0.8.2] - 2024-07-28

### Fixed

- Ensure storybook module and components module are loaded before checking
  whether module exports function.
- Fix menu stories not compiling under certain circumstances.

## [0.8.1] - 2024-07-28

### Fixed

- Declare `phoenix_storybook` as required dependency.

## [0.8.0] - 2024-07-28

### Added

- Set up design tokens and CSS for demo application based on Barker. Styles for
  all components will be added in the future.

### Changed

#### General

- Add documentation for the compile-time options of the builder macros.

#### Property list, stack, cluster, button, and button link component

- Add styles to demo application.
- Improve story and documentation.
- Mark components as `stable`.

#### Tab navigation and disclosure button component

- Add styles to demo application.
- Improve story and documentation.
- Mark component as `refining`.

#### Icon and icon sprite component

- Add styles to demo application.
- Add story for icon sprite.
- Rename `label` attribute to `text`.
- Rename `label_placement` attribute to `text_position`.
- Change type of `label_placement` attribute from atom to string for
  consistency.
- Use `before` and `after` as values for `text_position` instead of `left` and
  `right` to better apply to right-to-left languages. Rename default classes
  to `has-text-before` and `has-text-after` accordingly.
- Make `text_position` classes configurable.
- Add `right-to-left` variation group to icon story.
- Set `sprite_url` as a compile time option.
- Mark both components as `refining`.

#### Date, datetime, and time component

- Improve story and documentation.
- Mark components as `refining`.

### Fixed

- `attributes` for modifier variations weren't set correctly when map was
  lacking key.

## [0.7.0] - 2024-07-24

### Changed

- Use private `field_description`, `field_errors`, and `label` components in
  `field` component. Apply base class to `field_description` and `field_errors`
  components.
- Use plain `div` with `{base_class}-frame` class instead of nested `frame`
  component in `image` component. This `div` does not receive the `ratio`
  attribute anymore. Apply the ratio with a CSS selector on the root div
  instead (e.g. `.image.is-4-by-3 > .image-frame`).

### Removed

- `field_description` component.
- `field_errors` component.
- `label` component.

## [0.6.0] - 2024-07-23

### Added

- Add `Doggo.Storybook` and `mix dog.gen.stories` for generating
  `Phoenix.Storybook` stories for the configured components. The generated
  stories automatically render variation groups for all configured modifiers.
- Add `Doggo.modifier_classes/1`.
- Add `Doggo.modifier_class_name/2`.

### Changed

- Replace all function components defined in `Doggo` with build macros
  in `Doggo.Components`. This allows you to customize the modifier attributes,
  component names, base classes, and some other options at compile time.
- Make modifier class name builder configurable.
- Rename build macro for former `input` component to `field`.
- Configure `Gettext` module for `field` component (formerly `input`) via
  compile-time option instead of global attribute.
- Allow to set required text and required title attributes for input and label.
- Add `module` argument to `mix dog.modifiers` that points to the module
  in which the Doggo components are configured.
- Replace `placeholder` attribute with `placeholder_src` and
  `placeholder_content` attributes in `avatar` component.
- Replace `phx-feedback-for` attribute in favor of
  `Phoenix.Component.used_input?/1`.
- Don't use `h2` for `Doggo.page_header/1` sub title.
- Nest `vertical_nav_nested` component into `<div>`.
- Rename `drawer-nav-title` class in `vertical_nav_nested` component to be
  based on configured component name (default: `vertical-nav-nested-title`).
- Better consistency, various improvements and optimizations in all components.
- Revise The component type classification.
- Add maturity levels for all components (experimental, developing, refining,
  stable).
- Require `live_view ~> 1.0.0-rc.6`.

### Removed

- Remove `Phoenix.Storybook` stories bundled in the `priv` folder in favor of
  `mix dog.gen.stories` and `Doggo.Storybook`.
- Remove `Doggo.flash_group/1`.

### Upgrade Guide

1. For all Doggo components you were using, call the corresponding `build`
   macros in `Doggo.Components` in one of your modules and update your HEEx
   templates to call the generated functions instead of the ones from the
   `Doggo` module. See readme for installation details.
2. The previous Doggo version instructed you to configure a separate Storybook
   that reads the stories from the `priv` folder of the dependency. Remove that
   second Storybook and run
   `mix dog.gen.stories -m [component-module] -o [storybook-folder] -a` to
   generate stories for the configured Doggo components in the primary
   Storybook.
3. If you use `mix dog.modifiers` in a script, add the `--module` argument.
4. If you were setting the `gettext` attribute on the `input` component, pass
   the `gettext_module` option to `Doggo.Components.build_field/1` instead.

## [0.5.0] - 2024-02-12

### Added

- New component: `Doggo.alert_dialog/1`.
- New component: `Doggo.carousel/1`.
- New component: `Doggo.combobox/1`.
- New component: `Doggo.disclosure_button/1`.
- New component: `Doggo.menu/1`.
- New component: `Doggo.menu_bar/1`.
- New component: `Doggo.menu_button/1`.
- New component: `Doggo.menu_group/1`.
- New component: `Doggo.menu_item/1`.
- New component: `Doggo.menu_item_checkbox/1`.
- New component: `Doggo.menu_item_radio_group/1`.
- New component: `Doggo.radio_group/1`.
- New component: `Doggo.split_pane/1`.
- New component: `Doggo.tabs/1`.
- New component: `Doggo.toolbar/1`.
- New component: `Doggo.tree/1`.
- Storybook page about modifier classes.
- Mix task `mix dog.modifiers` to list all modifier classes.

### Changed

- Set `aria-invalid` and `aria-errormessage` attributes in `Doggo.input/1`
  component.
- Use buttons instead of links in `Doggo.action_bar/1`.
- Add `toolbar` role to `Doggo.action_bar/1`.
- Use `section` instead of `article` in `Doggo.modal/1`.
- Use `button` for close button in `Doggo.modal/1`.
- Add `dismissable` attribute to `Doggo.modal/1`.
- Remove `role` from `button_link/1`, add `class`.
- Rename `Doggo.drawer/1` slots to `header`, `main`, and `footer`.
- Rename `Doggo.drawer_nav/1`, `Doggo.drawer_nav_nested/1` and
  `Doggo.drawer_nav_section` to `Doggo.vertical_nav/1`,
  `Doggo.vertical_nav_nested/1` and `Doggo.vertical_nav_section/1`.
- Depend on `phoenix_storybook ~> 0.6.0`.

## [0.4.0] - 2023-12-31

### Added

- New component: `Doggo.cluster/1`.
- New component: `Doggo.toggle_button/1`.

### Changed

- Significant changes to `Doggo.alert/1` and `Doggo.flash_group/1`.
- Require `id` attribute for `Doggo.callout/1`.
- Add `:normal` as size for `Doggo.icon_sprite/1`.
- Remove `:error` variant in favor of `:danger`.
- Add `<span>` around text placeholder for `Doggo.avatar/1`.
- Add base class to `Doggo.image/1`, add `class` attribute.
- Rename `Doggo.frame/1` ratio classes from `x-to-x` to `x-by-x`.
- Add required `label` attribute to `Doggo.navbar/1`.
- Add `class` attribute to `:item` slot of `Doggo.navbar_items/1`.
- Add `required_title` attribute to `Doggo.label/1`.
- Change `description` attribute of `Doggo.field_description/1` to inner block.
- Require `id` attribute for `Doggo.drawer_section/1`.
- Add `aria-labelledby` attribute to `Doggo.drawer_section/1`.
- Require `id` and `label` attributes for `Doggo.drawer_nav/1`.
- Add `class` attribute to `Doggo.drawer_nav` item slot.
- Require `id` attribute for `Doggo.drawer_nested_nav/1`.
- Add `class` attribute to `Doggo.drawer_nested_nav` item slot.
- Add `close_label` attribute to `Doggo.modal/1`.

### Fixed

- Box header not rendered if only action slot is used without banner or title.
- Aria label of breadcrumb component not overridable.
- Radio groups and checkbox groups always marked as required.
- Missing datalist option text.

## [0.3.1] - 2023-12-28

### Changed

- Allow event name as string in `on_click` attributes of app bar and steps.

### Fixed

- Faulty application of the `on_click` attribute in `Doggo.steps/1`.

## [0.3.0] - 2023-12-27

### Added

- New component: `Doggo.avatar/1`.
- New component: `Doggo.badge/1`.
- New component: `Doggo.bottom_navigation/1`.
- New component: `Doggo.box/1`.
- New component: `Doggo.callout/1`.
- New component: `Doggo.fab/1`.
- New component: `Doggo.field_group/1`.
- New component: `Doggo.page_header/1`.
- New component: `Doggo.skeleton/1`.
- New component: `Doggo.steps/1`.
- New component: `Doggo.tag/1`.
- New component: `Doggo.tooltip/1`.
- Allow to visually hide labels.
- Support autocomplete via `<datalist>` in `input/1` component.
- `addon_left` and `addon_right` slots on the `input/1` component.
- `gettext` attribute on `Doggo.input/1`, giving you the choice to
  set the Gettext module locally.

## [0.2.1] - 2023-12-19

### Changed

- Ensure compatibility with Phoenix.HTML 4.0.

## [0.2.0] - 2023-12-17

### Added

- New `tab_navigation/1` component.
- New `frame/1` component.
- New `image/1` component.

## [0.1.5] - 2023-12-16

### Fixed

- Remove default value for `errors` attribute on `input` component.

## [0.1.4] - 2023-12-16

### Added

- Added storybook stories for the remaining components.

### Fixed

- Errors passed as an attribute to the `input/1` component were overridden.
- The `field_description/1` component had a stray `<li>` tag.

## [0.1.3] - 2023-12-15

### Fixed

- Added `priv/storybook` folder to package configuration.

## [0.1.2] - 2023-12-14

### Changed

- Added more storybook stories.

### Fixed

- Fixed attribute name for table rows.

## [0.1.1] - 2023-12-13

### Changed

- Storybook stories for more components and documentation improvements.

## [0.1.0] - 2023-12-13

Initial release.
