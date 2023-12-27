# Changelog

## Unreleased

### Added

- New component: `Doggo.avatar/1`.
- New component: `Doggo.badge/1`.
- New component: `Doggo.box/1`.
- New component: `Doggo.callout/1`.
- New component: `Doggo.fab/1`.
- New component: `Doggo.field_group/1`.
- New component: `Doggo.page_header/1`.
- New component: `Doggo.skeleton/1`.
- New component: `Doggo.tag/1`.
- Allow to visually hide labels.
- Added `gettext` attribute to `Doggo.input/1`, giving you the choice to
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
