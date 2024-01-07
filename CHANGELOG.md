# Changelog

## Unreleased

### Added

- New component: `Doggo.disclosure_button/1`.
- New component: `Doggo.radio_group/1`.
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
