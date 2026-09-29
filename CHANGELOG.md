# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.17.0] - 2026-09-29

### Added

- `Doggo.Components`: Accept module attributes and function calls in build options, and raise for an anonymous function.
- `Doggo.Components`: Add a `:diagnostics` application config. With `config :doggo, diagnostics: true`, components check the values they get at render and raise when a check fails.
- `Doggo.Components`: Under diagnostics, raise when `:rest` holds an attribute the component sets itself.
- `Doggo.Storybook`: Add a file input variation to the `field` story.
- `accordion`, `action_bar`, `alert`, `alert_dialog`, `app_bar`, `bottom_navigation`, `callout`, `carousel`, `combobox`, `fallback`, `icon`, `icon_sprite`, `menu_group`, `menu_item_radio_group`, `modal`, `page_header`, `property_list`, `switch`, `tabs`: Under diagnostics, raise for a blank accessible name.
- `accordion`, `action_bar`, `avatar`, `bottom_navigation`, `box`, `breadcrumb`, `card`, `field`, `icon`, `icon_sprite`, `radio_group`, `tree_item`: Add a class to every part.
- `action_bar`: Add `label` and `labelledby` attributes.
- `box`: Add a `heading` attribute.
- `box`: Add an `id` attribute. With it, the title and the body get `{id}-title` and `{id}-body`.
- `menu_item`, `menu_item_checkbox`, `toggle_button`: Accept an event name or a JS command in every callback attribute.
- `menu_item_checkbox`: Accept `:indeterminate` as `checked` value.
- `navbar`: Add a `labelledby` attribute.
- `property_list`: Add a `class` attribute to `:prop`.
- `table`: Add a `scrollable` attribute.
- `toggletip`: New component.
- `vertical_nav`: Add a `landmark` attribute.

### Changed

- `Doggo.Components`: Run the label checks only under diagnostics.
- `mix dog.safelist`: Document the output format, which only changes in a major release.
- `accordion`, `action_bar`, `bottom_navigation`, `carousel`, `drawer`, `menu`, `menu_bar`, `menu_group`, `menu_item_radio_group`, `navbar_items`, `property_list`, `steps`, `tab_navigation`, `tabs`, `vertical_nav`, `vertical_nav_nested`, `vertical_nav_section`: Render nothing without items.
- `accordion`: Require the `title` of `:section`.
- `action_bar`: Require `label` or `labelledby`.
- `alert_dialog`, `modal`: Replace `dismissable` with `closedby`, which takes `"any"`, `"closerequest"` or `"none"`.
- `alert_dialog`, `modal`: Set `data-cancel` to `on_cancel` only.
- `carousel`: Require the `label` of `:previous` and `:next`.
- `combobox`, `field`, `switch`: Set `dir="auto"` on text passed in attributes that is rendered next to the component's own text.
- `drawer`, `fallback`: Let a `role` in `:rest` replace the component's role.
- `field`: Replace the `extra_types` build option with `types`.
- `field`: Suffix the ids of the field's own parts with `-errors`, `-description` and `-datalist`, and derive option ids as `Phoenix.HTML.Form.input_id/3` does.
- `frame`, `image`: Turn `ratio` from a modifier into an attribute, with a `ratios` build option.
- `image`: Render the box with the `frame` build.
- `navbar`: Check `label` or `labelledby` with the label check instead of requiring `label` at compile time.
- `radio_group`: Suffix the ids of the group's own parts with `-errors` and `-description`, and derive option ids as `Phoenix.HTML.Form.input_id/3` does.
- `table`: Under diagnostics, raise for a scrollable table without `label` or `caption`.
- `tooltip`: Describe the control in the inner block, which receives the `aria-describedby` attribute through `:let`. Remove `contains_link`.
- `tree_item`: Only set `aria-selected` when `selected` is set.
- `vertical_nav`: Take exactly one name from `label`, `labelledby` or the `:title` slot.

### Fixed

- `Doggo.Components`: Keep LiveView's change tracking through derived assigns.
- `Doggo.Components`: List `alert_dialog` and `modal` under their own group in the documentation.
- `Doggo`: Escape the id in the selectors of `show_modal/2`, `hide_modal/2`, `show_tab/3` and the commands the disclosure components use.
- `alert_dialog`, `modal`: Run `on_cancel` once when the dialog is closed with `JS.exec("data-cancel")`.
- `breadcrumb`: Render nothing without items instead of raising a `MatchError`.
- `field`: List `data-addon`, `data-multiple` and `data-visually-hidden` in the safelist instead of `data-state`.
- `field`: Keep `aria-describedby` in step with the errors for a field without a form field.
- `field`: Omit `value` on a file input, and pass `multiple` on.
- `navbar_items`, `vertical_nav`, `vertical_nav_nested`: Omit an empty `class` attribute.
- `switch`, `toggle_button`: Render `nil` as `false`.
- `table`: Treat a blank `label` or `caption` as unset.
- `vertical_nav`: Accept a nav named only by its `:title` instead of raising.

### How to upgrade

- `Doggo.Components`: Enable the diagnostics in development and test. Without them, no render-time check runs, including the label checks that used to raise everywhere.

  ```diff
  # config/dev.exs and config/test.exs
  + config :doggo, diagnostics: true
  ```

- `accordion`: Set a `title` on every `:section`.
- `action_bar`: Pass `label` or `labelledby`.

  ```diff
  - <.action_bar id="dog-actions">
  + <.action_bar id="dog-actions" label="Dog actions">
  ```

- `alert_dialog`, `modal`: Replace `dismissable` with `closedby`.

  ```diff
  - <.modal id="pet-modal" dismissable={false}>
  + <.modal id="pet-modal" closedby="none">
  - <.alert_dialog id="end-session" dismissable>
  + <.alert_dialog id="end-session" closedby="any">
  ```

  `closedby="any"` is the default of `modal`, and `closedby="none"` the default of `alert_dialog`.

- `alert_dialog`, `modal`: Close the dialog with `hide_modal/1`. `data-cancel` only runs `on_cancel` now.

  ```diff
  - <.link phx-click={JS.exec("data-cancel", to: "#pet-modal")}>Close</.link>
  + <.link phx-click={Doggo.hide_modal("pet-modal")}>Close</.link>
  ```

- `carousel`: Set `label` on `:previous` and `:next`.

  ```diff
  - <:previous>Previous</:previous>
  + <:previous label="Previous slide">Previous</:previous>
  ```

- `field`: Rename the `extra_types` build option.

  ```diff
  - build_field(extra_types: %{"ranked" => &MyAppWeb.Inputs.ranked/1})
  + build_field(types: %{"ranked" => &MyAppWeb.Inputs.ranked/1})
  ```

- `field`, `radio_group`: Update CSS and tests that name the ids of a field's own parts, and option ids with spaces or punctuation.

  ```diff
  - #pet_breed_errors, #pet_breed_description, #pet_breed_datalist
  + #pet_breed-errors, #pet_breed-description, #pet_breed-datalist
  - #pet_tags_golden retriever
  + #pet_tags_golden_retriever
  ```

- `frame`, `image`: Replace the `ratio` modifier with the `ratios` build option, and `[data-ratio]` selectors with `[data-numerator]` and `[data-denominator]`.

  ```diff
  - build_frame(modifiers: [ratio: [values: ["1:1", "16:9"], default: "1:1"]])
  + build_frame(ratios: ["1:1", "16:9"])
  ```

- `image`: Build `frame` before `image`, or name the frame build.

  ```diff
  + build_frame()
    build_image()
  ```

- `table`: Name every scrollable table, or render it without a scroll container.

  ```diff
  - <.table id="pets" rows={@pets}>
  + <.table id="pets" rows={@pets} label="Pets">
  ```

  `caption` names the table as well, and renders a visible caption. For a table that fits its container, set `scrollable={false}` instead.

- `tooltip`: Spread the `:let` value on the control in the inner block, and remove `contains_link`.

  ```diff
  - <.tooltip id="labrador-info" contains_link>
  -   <.link navigate={~p"/labradors"} aria-describedby="labrador-info-tooltip">
  + <.tooltip id="labrador-info" :let={trigger}>
  +   <.link navigate={~p"/labradors"} {trigger}>
        Labrador Retriever
      </.link>
      <:tooltip>Friendly and good swimmers.</:tooltip>
    </.tooltip>
  ```

  A tooltip no longer makes plain text focusable. Show that information as visible text, or use `toggletip`.

- `vertical_nav`: Drop `label` or `labelledby` where a `:title` is given.

  ```diff
  - <.vertical_nav id="project-nav" label="Projects">
  + <.vertical_nav id="project-nav">
      <:title>Projects</:title>
  ```

## [0.16.1] - 2026-09-25

### Changed

- `tree_item`: Handle the `expanded` attribute as initial state only. The server cannot update it anymore.

### Fixed

- `Doggo.Components`: Raise at compile time when a modifier is named after a global HTML attribute.
- `Doggo.Components`: Raise at compile time when a modifier has the name of an attribute or slot of the component.
- `Doggo.Components`: Raise at compile time when `name` is a function that `Phoenix.Component` imports.
- `Doggo.Components`: Raise at compile time when a build macro is called in a module that does not `use Doggo.Components`.
- `accordion`: Raise an `ArgumentError` for an invalid `expanded` value.
- `fallback`: Render the placeholder for a string of only whitespace and when the formatter returns an empty string.
- `page_header`: Render a navigation entry without `href`, `navigate`, `patch` or `on_click` as its content instead of inside an empty link.
- `tree`: Keep the expanded state the user chose for a branch through LiveView patches, including patches of a LiveComponent inside the tree.
- `tree`: Keep the tab stop through patches of a LiveComponent inside the tree.
- `tree`: Stop `Up` and `Down` at the first and last item.
- `tree`: Ignore hidden text and icons in the type-ahead.
- `tree`: Stop the hook from failing on `Right` on an expanded branch without a group.

## [0.16.0] - 2026-09-22

### Added

- Example CSS: Add CSS examples for all remaining components.
- `table`: Add `label` attribute to name the scroll container.

### Changed

- All components: Update component categories.
- `app_bar`, `callout`, `drawer`: Name the landmarks the components render.
- `app_bar`, `drawer`: Require `id`.
- `callout`, `drawer`: Render as a `div` and only set `role="complementary"` if the component has a name in order to prevent unnamed landmarks.
- `field`: Use `-switch-state-on` and `-switch-state-off` classes on the switch instead of a `data-state` attribute.
- `modal`: Render the title before the close button.
- `switch`: Render both states at once and toggle `hidden` between them instead of rendering only the current one.
- `table`: Put the scroll container in the tab order, name it with `role="region"`, and set `scope="col"` on the header cells.

### Fixed

- `avatar`: Label an avatar that falls back to `placeholder_content`.
- `bottom_navigation`: Only set `aria-label` on an item when its label is hidden.
- `carousel`: Put the slide container in the tab order, so the slides can be scrolled by keyboard.
- `carousel`: Stop the rotation under the pointer after the pause button resumes it.
- `date`: Remove `form`, `name` and `value` as global attributes.
- `menu_button`: Close the menu when clicking outside it.

### How to upgrade

- `app_bar`, `drawer`: Pass an `id`.
- `callout`, `drawer`: If your CSS or tests select the `aside` element the components used to render, select the base class instead.
- `mix dog.gen.stories`: Because the component categories were updated, the location of the stories also changed. Run `mix dog.gen.stories` again and delete the stories from their old folder.
- `field`: Replace `[data-state]` selectors on the switch with `.field-switch-state-on` and `.field-switch-state-off`.

## [0.15.1] - 2026-09-11

### Fixed

- `carousel`: Prevent pagination dots from flickering while scrolling.

## [0.15.0] - 2026-09-11

### Added

- All components: Add a `labelledby` attribute to all components that take a `label`.
- JavaScript hooks: Publish the JavaScript hooks as ES modules, on npm as `@woylie/doggo` and in the Hex package under `assets/js`. See the README for both install routes.
- `accordion`, `action_bar`, `alert_dialog`, `combobox`, `menu`, `menu_bar`, `menu_button`, `modal`, `split_pane`, `tabs`, `toolbar`, `tooltip`, `tree`, `tree_item`: Add hooks and keyboard support.
- `alert`: Add a `:close` slot for the content of the close button.
- `callout`: Add an `:action` slot.
- `callout`: Add an `:action` slot.
- `carousel`: Add a `loop` attribute, default `true`. With `loop={false}`, the first and last slide don't wrap around.
- `carousel`: Add a `rotation_interval_ms` attribute, default `5000`.
- `carousel`: Add `Home` and `End` key handlers to the pagination, which move to the first and last slide.
- `combobox`: Support options written as keyword lists and maps, with `description` and `disabled` keys, and support option groups and `:hr` separators.
- `combobox`: Add a `display_value` attribute to set the text shown for the selected value.
- `combobox`: Add an `on_search` attribute to filter the options on the server instead of in the browser.
- `combobox`: Add `free_text` and `free_text_label` attributes, which let the user submit what they typed when it is not among the options.
- `combobox`: Add a `clearable` attribute, which renders a button that unselects, and a `clear_label` attribute for its accessible name.
- `combobox`: Add `:clear` and `:toggle` slots for the content of the two buttons.
- `combobox`: Add an example stylesheet.
- `field`: Add an `:extra_types` builder option for rendering a type with your own component.
- `field`: Add a `hidden_input` attribute to omit the hidden input that submits `false` for an unchecked checkbox.
- `field`: Support nested options in the `checkbox-group` and `radio-group` types.
- `field`: Support options written as keyword lists, and support option descriptions.
- `split_pane`: Make the panes resizable by dragging the separator or by moving it with the keyboard.
- `tabs`: Add an `orientation` attribute.
- `tree_item`: Add `expanded` and `selected` attributes.

### Changed

- All components: Reject a blank `label` or `labelledby`.
- `action_bar`, `combobox`, `drawer`, `menu`, `menu_bar`, `menu_button`, `menu_group`, `menu_item`, `menu_item_checkbox`, `menu_item_radio_group`, `radio_group`, `split_pane`, `switch`, `toolbar`, `tree`, `tree_item`: Raise the maturity level from experimental to developing, most of them because they gained their hook and keyboard support in this release.
- `alert`: Change the type of the `close_label` attribute to `:string`.
- `alert`: Remove the click handler from the root element.
- `alert_dialog`, `modal`: Use `showModal()` to open dialogs to provide proper modal semantics. This adds support for the CSS `::backdrop` pseudo element and ensures scroll locking without relying on CSS or JS.
- `alert_dialog`, `modal`: Close dialogs with the `closedby` attribute.
- `alert_dialog`, `modal`: Support the Invoker Commands API.
- `alert_dialog`, `modal`: Remove the `modal-container` and `alert-dialog-container` element.
- `app_bar`: Require the `label` attribute of the `:navigation` and `:action` slots.
- `app_bar`: Set `aria-label` on the `:navigation` and `:action` links.
- `bottom_navigation`: Require the `label` attribute of the `:item` slot.
- `bottom_navigation`, `breadcrumb`, `steps`, `tab_navigation`, `vertical_nav`: Require a `label` or a `labelledby`, and remove the default labels of `breadcrumb`, `steps` and `tab_navigation`.
- `button`, `toggle_button`: Default the `disabled` attribute to `false` instead of `nil`.
- `button_link`: Prevent activation of a disabled button link. The link is now rendered without a destination and with `role="link"` and `aria-disabled="true"`.
- `button_link`: Remove the `data-disabled` attribute. The state is expressed with `aria-disabled` instead.
- `callout`: Rename the default `variant` modifier to `level`.
- `card`: Rename the `:main` slot to `:body`.
- `carousel`: Replace the `auto_rotation` attribute with a `:pause` slot, which renders the button that stops and restarts the rotation. The rotation is enabled by the presence of the slot, so a rotating carousel always has a button to stop it, as WCAG 2.2.2 requires.
- `carousel`: Complete the tablist of the pagination: `role="tablist"` is set on the `carousel-pagination` element instead of a nested `div`, each button has an `id`, `aria-selected` and `tabindex`, and the slides are the tab panels the buttons select. The button contains a single `span` instead of two nested ones.
- `carousel`: Label the pagination buttons with the `label` of the slide they select. `pagination_slide_label` is only used for slides without a label.
- `carousel`: Set `aria-live` to `off` while rotating and to `polite` while stopped.
- `carousel`: Move by setting `scrollLeft` on the scroll container, so that the `scroll-behavior` property decides whether the movement is animated.
- `carousel`: Render no controls and no pagination for a single item. The item is a group instead of a tab panel then.
- `carousel`: Mark the component as `developing`.
- `combobox`: Render the listbox as a `div` with `role="listbox"` and each option as a `div` with `role="option"`, instead of a `ul` with `li` elements.
- `page_header`: Render the title and the subtitle in an `hgroup` instead of a `div` with the `page-header-title` class.
- `property_list`: Require the `:prop` slot.
- `tabs`: Require the `label` attribute of the `:panel` slot.
- `toolbar`: Add an `orientation` attribute.
- `action_bar`, `menu`, `menu_bar`, `toolbar`, `tree`, `vertical_nav`: Require the `id` attribute.
- `navbar_items`, `vertical_nav`, `vertical_nav_nested`: Change `class` attribute of the item slots to `:any`, so that a list of classes can be passed.

### Removed

- `combobox`: Remove support for options written as `{label, value, description}` tuples. Write the option as a keyword list with a `description` key instead.

### Fixed

- `card`: Render the main content as a `div` instead of a `main` element. A document may hold only one `main`, so a page of cards was invalid and exposed one `main` landmark per card.
- `carousel`: Scroll to the right slide if the slides have different widths, or if `scroll-snap-align` is not `start`. The scroll position was calculated from the width of the first slide.
- `carousel`: Render the pause button first and the pagination between the previous and next buttons, so that the tab order matches the visual order.
- `carousel`: Keep working after a LiveView patch that adds or removes slides. Buttons rendered by the patch did nothing, and the active slide could point at a slide that had been removed.
- `carousel`: Stop the rotation timer when the element is removed. It kept running against a detached element and held it from being collected.
- `cluster`: Remove the `role="group"` attribute.
- `combobox`: Mark the option holding the value as selected when the option values are not strings.
- `combobox`: Mark only the first option when several options hold the same value.
- `combobox`: Render an option with an empty value for `nil` and for an empty label, so that a blank option can be selected.
- `field`: Describe an errored field by its error text through `aria-describedby` in addition to `aria-errormessage`.
- `field`: Always render the error list as an `aria-live="polite"` region, so that an error that appears after load is announced.
- `field`: Render a field built without `field` assign from just a `name` and `value`.
- `field`: Render options given as keyword lists.
- `frame`: Default to a `1:1` ratio instead of raising when no `ratio` is given.
- `image`: Pass a valid `ratio` in the story.
- `page_header`: Add the missing `on_click` attribute to the `:navigation` slot.
- `split_pane`: Clamp the `aria-valuenow` of the separator between `min_size` and `max_size`.
- `tree_item`: Render the expanded and collapsed state correctly.

### How to upgrade

- `button_link`: Replace `[data-disabled]` with `[aria-disabled]` in any styles you wrote for disabled button links.
- `button_link`: A disabled button link no longer renders an `href`. Revisit any style or test that selects `a.button[href]`.
- `property_list`: Add a `:prop` slot to any property list that has none, or remove the component from that call site.
- `card`: Rename the `:main` slot to `:body`, and replace `main` with `.card-body` in any styles you wrote for it.
- All components: Ensure to pass a `label` or `labelledby` attribute to every component that expects them.
- `action_bar`, `menu`, `menu_bar`, `toolbar`, `tree`, `vertical_nav`: Set an `id` on every instance.
- `callout`: Rename `variant` to `level` if you use the defaults, and change `[data-variant]` to `[data-level]` in your CSS.
- JavaScript hooks: Register the hooks of the components you build. See the README.
- `combobox`: Rewrite any styles that select the listbox or its options as `ul` and `li`. They are `div` elements with `role="listbox"` and `role="option"` now.
- `combobox`: Rewrite options given as `{label, value, description}` tuples as keyword lists with a `description` key.
- `alert_dialog`, `modal`: Remove the backdrop and scroll locking you added and style `::backdrop` instead.
- `alert_dialog`, `modal`: Move any styles on `.modal-container` and `.alert-dialog-container` to the `dialog` element itself. The element is gone, and the dialog is the box now that it opens in the top layer.
- `field`: An empty `.field-errors` element is now part of the layout. See the _Field error announcements_ section of the README for the CSS that removes it from the flow without removing it from the accessibility tree.
- `carousel`: Replace the `auto_rotation` attribute with a `:pause` slot.
- `carousel`: In pagination styles, `[role="tablist"]` is now the `carousel-pagination` element itself rather than a child of it, and the dot is `button > span` rather than `button > span > span`.
- `carousel`: Set `label` on every `:item` of a carousel with `pagination`, since the pickers take their names from it. `pagination_slide_label` now applies only to slides without a label.
- `carousel`: A carousel with a single item renders no `carousel-controls` element anymore. Update your styles to account for its absence if necessary.

## [0.14.9] - 2026-08-27

### Changed

- All components: Document the CSS rule the `data-visually-hidden` attribute needs, and why `display: none` is the wrong one.
- `icon`, `toolbar`: Document that omitting the `text` attribute of `icon` leaves the icon without an accessible name, and correct the examples that omitted it. The `toolbar` examples passed a `label` attribute, which `icon` does not have.
- `alert_dialog`, `modal`: Document that the components are not modal in the browser's sense, so the caller has to supply a backdrop and lock scrolling.
- `table`: Document that the `row_click` attribute is available to pointer users only, and that every action reachable through it needs a focusable equivalent in the row.

### Fixed

- `Doggo.Storybook`: Resolve the `:module` option of `use Doggo.Storybook` in the caller's environment, so that a story module can refer to its components module through an alias.
- `action_bar`: Set `aria-label` on the buttons, taken from the required `label` of the item. The name previously came from `title` alone.
- `action_bar`, `alert`, `alert_dialog`, `combobox`, `modal`: Set `type="button"` on the buttons the components generate. Without it they defaulted to `submit` and submitted any form they sat in.
- `alert_dialog`, `modal`: Remove the `href` attribute from the close button, which is not valid on a `button` element.
- `fallback`, `vertical_nav_section`: Set `role="img"` on the placeholder of `fallback` and `role="group"` on a titled `vertical_nav_section`. Both put an accessible name on an element whose implicit role prohibits one, so the name was dropped.
- `field`: Omit the `data-addon` attribute when neither addon slot is filled. It was tested with `&&`, and an empty slot is truthy, so every field rendered `data-addon="left right"`.
- `alert_dialog`, `modal`: Focus the container rather than the content, so that a dialog whose body holds nothing focusable still moves focus into the dialog.
- `steps`: Remove the builder options the documentation listed. None of `:current_class`, `:completed_class`, `:upcoming_class` and `:visually_hidden_class` exists, so following the documentation raised an `ArgumentError` at compile time.

## [0.14.8] - 2026-08-27

### Security

- `date`: Remove field values that are not a valid ISO 8601 date instead of truncating them to ten characters.
- `field`: Fix HTML injection in the `date` input, which marked the field value as already escaped. A value taken from user params could break out of the `value` attribute. Present since 0.1.0.

## [0.14.7] - 2026-07-24

### Changed

- `carousel`: Change hook name to `Doggo.Components.Carousel.Hook`.
- `carousel`: Support scrolling and swiping on mobile devices.
- `carousel`: Add auto rotation.
- `carousel`: Add items container for more flexible styling.

## [0.14.6] - 2026-06-11

### Changed

- Dependencies: Loosen `phoenix_live_view` version requirement to ~> 1.1.
- JavaScript hooks: Add colocated JS hook for carousel pagination.
- `carousel`: Add example CSS styles.

## [0.14.5] - 2026-05-15

### Fixed

- Dependencies: Remove a type warning in Elixir 1.20.0-rc.5.

## [0.14.4] - 2026-04-09

### Fixed

- `icon`: Map icon names to functions at build time, so that an icon renders before its function name atom exists.

## [0.14.3] - 2026-04-08

### Changed

- `icon`: Simplify example styles.

### Fixed

- `Doggo.Storybook`: Handle modifiers without values and boolean modifiers in stories.
- `icon`: Remove extraneous whitespace.

## [0.14.2] - 2026-04-07

### Fixed

- `Doggo.Storybook`: Render all configured icons in the icon story instead of only the first one.

## [0.14.1] - 2026-04-07

### Fixed

- `Doggo.Storybook`: Toggle the `hidden` attribute in the toggle button story.
- `Doggo.Storybook`: Set class name as string in the container function of some stories.

## [0.14.0] - 2026-03-16

### Changed

- `image`: Move `data-numerator` and `data-denominator` attributes to inner `image-frame` element.

### Fixed

- `image`: Add modifier data attributes.

### How to upgrade

Before:

```html
<figure class="image" data-numerator="16" data-denominator="9">
  <div class="image-frame">
    <img src="" alt="" loading="" />
  </div>
  <figcaption></figcaption>
</figure>
```

After:

```html
<figure class="image">
  <div class="image-frame" data-numerator="16" data-denominator="9">
    <img src="" alt="" loading="" />
  </div>
  <figcaption></figcaption>
</figure>
```

## [0.13.3] - 2026-03-14

### Changed

- `button`: Allow `popovertarget` attribute.

## [0.13.2] - 2026-03-04

### Changed

- Dependencies: Require `phoenix_storybook` `~> 1.0`.

## [0.13.1] - 2026-02-16

### Changed

- `Doggo.Components`: Add `@doc type: {type}` tags to compiled components for ExDoc grouping.

## [0.13.0] - 2026-02-05

**This release contains significant breaking changes. Check your component styles carefully when upgrading.**

### Added

- `Doggo.Components`: Add `:type` option to modifiers, so that any attribute type can be used instead of only strings.

### Changed

- `Doggo`: Rename `Doggo.classes/1` to `Doggo.safelist/1`.
- `Doggo.Components`: Use `data-` attributes instead of classes for modifiers (see upgrade guide below).
- `mix dog.classes`: Rename `mix dog.classes` to `mix dog.safelist`.
- `mix dog.safelist`: Include data attributes in `mix dog.safelist` and `Doggo.safelist/1` output.
- `button_link`: Remove `disabled_class` option.
- `button_link`: Use `data-disabled` attribute instead of the `disabled_class` (selector: `[data-disabled]`).
- `field`: Remove `addon_left_class`, `addon_right_class`, and `visually_hidden_class` options.
- `field`: Use `data-addon` attribute instead of `addon_left_class` and `addon_right_class` (selectors: `[data-addon~="left"]`, `[data-addon~="right"])`.
- `field`: Use `data-invalid` attribute instead of `has-errors` class (selector: `[data-invalid]`).
- `field`: Use `data-state` attribute instead of `{base_class}-switch-state-{on|off}` classes (selectors: `[data-state="on"]`, `[data-state="off"]`).
- `frame`: Make `ratio` required.
- `frame`, `image`: Change format of `ratio` attribute (before: `16-by-9`, after: `16:9`).
- `frame`, `image`: Use `data-numerator` and `data-denominator` attributes instead of adding a class for the ratio (before: `class="is-16-by-9"`, after: `data-numerator="16" data-denominator="9"`).
- `icon`, `icon_sprite`: Remove `text_position_after_class`, `text_position_before_class`, `text_position_hidden_class`, and `visually_hidden_class` options.
- `icon`, `icon_sprite`: Use `data-text-position` class instead of `text_position_*` classes (selectors: `[data-text-position="before"]`, `[data-text-position="after"]`, `[data-text-position="hidden"]`).
- `stack`: Remove `recursive_class` option.
- `stack`: Use `data-recursive` attribute instead of `recursive_class` (selector: `[data-recursive]`).
- `steps`: Use `data-visually-hidden` attribute instead of `visually_hidden_class` (selector: `[data-visually-hidden]`).
- `steps`: Use `data-visually-hidden` attribute instead of `visually_hidden_class` (selector: `[data-visually-hidden]`).
- `steps`: Remove `current_class`, `completed_class`, `upcoming_class`, and `visually_hidden_class` options.
- `steps`: Use `data-visually-hidden` attribute instead of `visually_hidden_class` (selector: `[data-visually-hidden]`).
- `steps`: Use `data-state` attribute instead of `current_class`, `completed_class`, and `upcoming_class` (selectors: `[data-state="current"]`, `[data-state="completed"]`, `[data-state="upcoming"]`).

### Removed

- `Doggo`: Remove `Doggo.modifier_class_name/2`.
- `Doggo.Components`: Remove `class_name_fun` option.

### How to upgrade

In previous versions, modifier attribute values would be reflected with CSS classes in the HTML output.

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

The implementation was changed to use separate data attributes for each modifier instead. Now, the generated HTML will look like this:

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

- `icon`: Render the inner SVG with a referenced icon module instead of using an inner block.
- `page_header`: Add `navigation` slot.

## [0.11.0] - 2025-12-16

### Added

- `mix dog.classes`: Add `--check` switch to `mix dog.classes`.

### Changed

- Dependencies: Require `phoenix_live_view` `~> 1.1.0` and `phoenix_storybook` `~> 0.9`.

## [0.10.8] - 2025-09-15

### Changed

- Dependencies: Support `gettext` `~> 1.0`.

## [0.10.7] - 2025-07-31

### Changed

- Dependencies: Require `phoenix_live_view` `~> 1.0.6 or ~> 1.1.0`.

## [0.10.6] - 2025-07-08

### Changed

- Dependencies: Loosen version requirement for `phoenix_storybook`.

## [0.10.5] - 2025-06-10

### Fixed

- `radio_group`: Add `required` attribute to radio inputs.

## [0.10.4] - 2025-02-22

### Fixed

- `field`: Escape select option values.

## [0.10.3] - 2025-02-11

### Changed

- `field`: Build select options with function components instead of `Phoenix.HTML.Form.options_for_select/2`.

## [0.10.2] - 2025-01-08

### Changed

- Dependencies: Require Phoenix LiveView ~> 1.0.0.
- Dependencies: Support Phoenix Storybook 0.8.

## [0.10.1] - 2024-11-20

### Changed

- Dependencies: Support Phoenix Storybook 0.7.x.

## [0.10.0] - 2024-11-19

### Changed

- `field`: Remove `required_text` attribute in favor of a compile-time option passed to `build_field/1`.
- `field`: Remove `required_title` attribute; remove `title` from `span` element.
- `field`: Change default for `required_text` from `*` to `(required)`.
- `field`: Translate `required_text` with Gettext module, if set.
- `field`: Add `optional_text` option to `build_field/1` to mark optional fields with a label suffix. Defaults to `nil`.
- `field`: Prefix `checkbox`, `checkbox-group`, `radio-group`, `required-mark`, `select`, `switch`, `switch-label`, `switch-state`, `switch-state-off`, and `switch-state-on` classes with base class for consistency.

## [0.9.1] - 2024-10-18

### Changed

- `mix dog.classes`: Add header to file output of `mix dog.classes`.

### Fixed

- Dependencies: Remove a deprecation warning in Phoenix LiveView 1.0.7-rc.7.

## [0.9.0] - 2024-09-25

### Changed

- `mix dog.modifiers`: Rename `Doggo.modifier_classes/1` to `Doggo.classes/1` and `mix dog.modifiers` to `mix dog.classes`. The function and mix task return all base classes, nested classes, and additional customizable classes in addition to the modifier classes now.
- `box`: Wrap inner block into `div`.
- `box`, `tag`: Add example styles.

### Removed

- `fab`: Remove the component. It might have made sense to have it as a separate component before components could be customized, but since the semantics are the same as a regular button, you can just make one with `build_button(name: :fab, base_class: "fab")` if you need it.

## [0.8.2] - 2024-07-28

### Fixed

- `Doggo.Storybook`: Ensure storybook module and components module are loaded before checking whether module exports function.
- `Doggo.Storybook`: Compile the menu stories under all circumstances.

## [0.8.1] - 2024-07-28

### Fixed

- Dependencies: Declare `phoenix_storybook` as required dependency.

## [0.8.0] - 2024-07-28

### Added

- Example CSS: Set up design tokens and CSS for demo application based on Barker. Styles for all components will be added in the future.

### Changed

- `Doggo.Components`: Add documentation for the compile-time options of the builder macros.
- `date`, `datetime`: Improve story and documentation.
- `date`, `datetime`: Improve story and documentation.
- `date`, `datetime`: Improve story and documentation.
- `date`, `datetime`: Mark components as `refining`.
- `icon`: Add `right-to-left` variation group to the story.
- `icon`, `icon_sprite`: Add styles to demo application.
- `icon`, `icon_sprite`: Add styles to demo application.
- `icon`, `icon_sprite`: Add styles to demo application.
- `icon`, `icon_sprite`: Rename `label` attribute to `text`.
- `icon`, `icon_sprite`: Rename `label_placement` attribute to `text_position`.
- `icon`, `icon_sprite`: Change type of `label_placement` attribute from atom to string for consistency.
- `icon`, `icon_sprite`: Use `before` and `after` as values for `text_position` instead of `left` and `right` to better apply to right-to-left languages. Rename default classes to `has-text-before` and `has-text-after` accordingly.
- `icon`, `icon_sprite`: Make `text_position` classes configurable.
- `icon`, `icon_sprite`: Set `sprite_url` as a compile time option.
- `icon`, `icon_sprite`: Mark both components as `refining`.
- `icon_sprite`: Add story.
- `button`, `cluster`, `property_list`, `stack`: Mark components as `stable`.
- `disclosure_button`, `tab_navigation`: Mark component as `refining`.

### Fixed

- `Doggo.Components`: Set `attributes` for modifier variations when the map lacks a key.

## [0.7.0] - 2024-07-24

### Changed

- `field`: Use private `field_description`, `field_errors`, and `label` components. Apply base class to `field_description` and `field_errors` components.
- `image`: Use plain `div` with `{base_class}-frame` class instead of nested `frame` component. This `div` does not receive the `ratio` attribute anymore. Apply the ratio with a CSS selector on the root div instead (e.g. `.image.is-4-by-3 > .image-frame`).

### Removed

- `field_description`: Remove the component.
- `field_errors`: Remove the component.
- `label`: Remove the component.

## [0.6.0] - 2024-07-23

### Added

- `Doggo`: Add `Doggo.modifier_classes/1`.
- `Doggo`: Add `Doggo.modifier_class_name/2`.
- `mix dog.gen.stories`: Add `Doggo.Storybook` and `mix dog.gen.stories` for generating `Phoenix.Storybook` stories for the configured components. The generated stories automatically render variation groups for all configured modifiers.

### Changed

- All components: Improve consistency across all components, with various smaller improvements and optimizations.
- All components: Revise The component type classification.
- All components: Add maturity levels for all components (experimental, developing, refining, stable).
- Dependencies: Require `live_view ~> 1.0.0-rc.6`.
- `Doggo.Components`: Replace all function components defined in `Doggo` with build macros in `Doggo.Components`. This allows you to customize the modifier attributes, component names, base classes, and some other options at compile time.
- `Doggo.Components`: Make modifier class name builder configurable.
- `mix dog.modifiers`: Add `module` argument to `mix dog.modifiers` that points to the module in which the Doggo components are configured.
- `avatar`: Replace `placeholder` attribute with `placeholder_src` and `placeholder_content` attributes.
- `field`: Configure `Gettext` module (formerly on `input`) via compile-time option instead of global attribute.
- `field`: Replace `phx-feedback-for` attribute in favor of `Phoenix.Component.used_input?/1`.
- `field`, `input`: Rename build macro for former `input` component to `field`.
- `input`, `label`: Allow to set required text and required title attributes.
- `page_header`: Don't use `h2` for sub title.
- `vertical_nav_nested`: Nest into `<div>`.
- `vertical_nav_nested`: Rename `drawer-nav-title` class to be based on configured component name (default: `vertical-nav-nested-title`).

### Removed

- `mix dog.gen.stories`: Remove `Phoenix.Storybook` stories bundled in the `priv` folder in favor of `mix dog.gen.stories` and `Doggo.Storybook`.
- `flash_group`: Remove the component.

### How to upgrade

1. For all Doggo components you were using, call the corresponding `build` macros in `Doggo.Components` in one of your modules and update your HEEx templates to call the generated functions instead of the ones from the `Doggo` module. See readme for installation details.
2. The previous Doggo version instructed you to configure a separate Storybook that reads the stories from the `priv` folder of the dependency. Remove that second Storybook and run `mix dog.gen.stories -m [component-module] -o [storybook-folder] -a` to generate stories for the configured Doggo components in the primary Storybook.
3. If you use `mix dog.modifiers` in a script, add the `--module` argument.
4. If you were setting the `gettext` attribute on the `input` component, pass the `gettext_module` option to `Doggo.Components.build_field/1` instead.

## [0.5.0] - 2024-02-12

### Added

- `Doggo.Storybook`: Add a storybook page about modifier classes.
- `mix dog.modifiers`: Add `mix dog.modifiers` to list all modifier classes.
- `alert_dialog`: New component.
- `carousel`: New component.
- `combobox`: New component.
- `disclosure_button`: New component.
- `menu`: New component.
- `menu_bar`: New component.
- `menu_button`: New component.
- `menu_group`: New component.
- `menu_item`: New component.
- `menu_item_checkbox`: New component.
- `menu_item_radio_group`: New component.
- `radio_group`: New component.
- `split_pane`: New component.
- `tabs`: New component.
- `toolbar`: New component.
- `tree`: New component.

### Changed

- Dependencies: Depend on `phoenix_storybook ~> 0.6.0`.
- `action_bar`: Use buttons instead of links.
- `action_bar`: Add `toolbar` role.
- `button_link`: Remove `role`, add `class`.
- `drawer`: Rename slots to `header`, `main`, and `footer`.
- `drawer_nav`, `drawer_nav_nested`, `drawer_nav_section`: Rename to `vertical_nav`, `vertical_nav_nested` and `vertical_nav_section`.
- `input`: Set `aria-invalid` and `aria-errormessage` attributes.
- `modal`: Use `section` instead of `article`.
- `modal`: Use `button` for close button.
- `modal`: Add `dismissable` attribute.

## [0.4.0] - 2023-12-31

### Added

- `cluster`: New component.
- `toggle_button`: New component.

### Changed

- All components: Remove `:error` variant in favor of `:danger`.
- `alert`, `flash_group`: Change both components significantly.
- `avatar`: Add `<span>` around text placeholder.
- `callout`: Require `id` attribute.
- `drawer_nav`: Require `id` and `label` attributes.
- `drawer_nav`: Add `class` attribute to item slot.
- `drawer_nested_nav`: Require `id` attribute.
- `drawer_nested_nav`: Add `class` attribute to item slot.
- `drawer_section`: Require `id` attribute.
- `drawer_section`: Add `aria-labelledby` attribute.
- `field_description`: Change `description` attribute to inner block.
- `frame`: Rename ratio classes from `x-to-x` to `x-by-x`.
- `icon_sprite`: Add `:normal` as size.
- `image`: Add base class, add `class` attribute.
- `label`: Add `required_title` attribute.
- `modal`: Add `close_label` attribute.
- `navbar`: Add required `label` attribute.
- `navbar_items`: Add `class` attribute to `:item` slot.

### Fixed

- `box`: Render the header when only the action slot is used, without banner or title.
- `breadcrumb`: Let the aria label be overridden.
- `input`: Mark radio groups and checkbox groups as required only when they are.
- `input`: Render the text of datalist options.

## [0.3.1] - 2023-12-28

### Changed

- `app_bar`, `steps`: Allow event name as string in `on_click` attributes.

### Fixed

- `steps`: Apply the `on_click` attribute correctly.

## [0.3.0] - 2023-12-27

### Added

- `avatar`: New component.
- `badge`: New component.
- `bottom_navigation`: New component.
- `box`: New component.
- `callout`: New component.
- `fab`: New component.
- `field_group`: New component.
- `input`: Support autocomplete via `<datalist>`.
- `input`: Add `addon_left` and `addon_right` slots.
- `input`: Add `gettext` attribute, giving you the choice to set the Gettext module locally.
- `label`: Allow to visually hide labels.
- `page_header`: New component.
- `skeleton`: New component.
- `steps`: New component.
- `tag`: New component.
- `tooltip`: New component.

## [0.2.1] - 2023-12-19

### Changed

- Dependencies: Ensure compatibility with Phoenix.HTML 4.0.

## [0.2.0] - 2023-12-17

### Added

- `frame`: New component.
- `image`: New component.
- `tab_navigation`: New component.

## [0.1.5] - 2023-12-16

### Fixed

- `input`: Remove default value for `errors` attribute.

## [0.1.4] - 2023-12-16

### Added

- `Doggo.Storybook`: Add storybook stories for the remaining components.

### Fixed

- `field_description`: Remove a stray `<li>` tag.
- `input`: Keep errors passed as an attribute instead of overriding them.

## [0.1.3] - 2023-12-15

### Fixed

- `Doggo.Storybook`: Add the `priv/storybook` folder to the package configuration.

## [0.1.2] - 2023-12-14

### Changed

- `Doggo.Storybook`: Add more storybook stories.

### Fixed

- `table`: Use the correct attribute name for rows.

## [0.1.1] - 2023-12-13

### Changed

- `Doggo.Storybook`: Add storybook stories for more components, and improve the documentation.

## [0.1.0] - 2023-12-13

Initial release.

[Unreleased]: https://github.com/woylie/doggo/compare/0.17.0...HEAD
[0.17.0]: https://github.com/woylie/doggo/compare/0.16.1...0.17.0
[0.16.1]: https://github.com/woylie/doggo/compare/0.16.0...0.16.1
[0.16.0]: https://github.com/woylie/doggo/compare/0.15.1...0.16.0
[0.15.1]: https://github.com/woylie/doggo/compare/0.15.0...0.15.1
[0.15.0]: https://github.com/woylie/doggo/compare/0.14.9...0.15.0
[0.14.9]: https://github.com/woylie/doggo/compare/0.14.8...0.14.9
[0.14.8]: https://github.com/woylie/doggo/compare/0.14.7...0.14.8
[0.14.7]: https://github.com/woylie/doggo/compare/0.14.6...0.14.7
[0.14.6]: https://github.com/woylie/doggo/compare/0.14.5...0.14.6
[0.14.5]: https://github.com/woylie/doggo/compare/0.14.4...0.14.5
[0.14.4]: https://github.com/woylie/doggo/compare/0.14.3...0.14.4
[0.14.3]: https://github.com/woylie/doggo/compare/0.14.2...0.14.3
[0.14.2]: https://github.com/woylie/doggo/compare/0.14.1...0.14.2
[0.14.1]: https://github.com/woylie/doggo/compare/0.14.0...0.14.1
[0.14.0]: https://github.com/woylie/doggo/compare/0.13.3...0.14.0
[0.13.3]: https://github.com/woylie/doggo/compare/0.13.2...0.13.3
[0.13.2]: https://github.com/woylie/doggo/compare/0.13.1...0.13.2
[0.13.1]: https://github.com/woylie/doggo/compare/0.13.0...0.13.1
[0.13.0]: https://github.com/woylie/doggo/compare/0.12.0...0.13.0
[0.12.0]: https://github.com/woylie/doggo/compare/0.11.0...0.12.0
[0.11.0]: https://github.com/woylie/doggo/compare/0.10.8...0.11.0
[0.10.8]: https://github.com/woylie/doggo/compare/0.10.7...0.10.8
[0.10.7]: https://github.com/woylie/doggo/compare/0.10.6...0.10.7
[0.10.6]: https://github.com/woylie/doggo/compare/0.10.5...0.10.6
[0.10.5]: https://github.com/woylie/doggo/compare/0.10.4...0.10.5
[0.10.4]: https://github.com/woylie/doggo/compare/0.10.3...0.10.4
[0.10.3]: https://github.com/woylie/doggo/compare/0.10.2...0.10.3
[0.10.2]: https://github.com/woylie/doggo/compare/0.10.1...0.10.2
[0.10.1]: https://github.com/woylie/doggo/compare/0.10.0...0.10.1
[0.10.0]: https://github.com/woylie/doggo/compare/0.9.1...0.10.0
[0.9.1]: https://github.com/woylie/doggo/compare/0.9.0...0.9.1
[0.9.0]: https://github.com/woylie/doggo/compare/0.8.2...0.9.0
[0.8.2]: https://github.com/woylie/doggo/compare/0.8.1...0.8.2
[0.8.1]: https://github.com/woylie/doggo/compare/0.8.0...0.8.1
[0.8.0]: https://github.com/woylie/doggo/compare/0.7.0...0.8.0
[0.7.0]: https://github.com/woylie/doggo/compare/0.6.0...0.7.0
[0.6.0]: https://github.com/woylie/doggo/compare/0.5.0...0.6.0
[0.5.0]: https://github.com/woylie/doggo/compare/0.4.0...0.5.0
[0.4.0]: https://github.com/woylie/doggo/compare/0.3.1...0.4.0
[0.3.1]: https://github.com/woylie/doggo/compare/0.3.0...0.3.1
[0.3.0]: https://github.com/woylie/doggo/compare/0.2.1...0.3.0
[0.2.1]: https://github.com/woylie/doggo/compare/0.2.0...0.2.1
[0.2.0]: https://github.com/woylie/doggo/compare/0.1.5...0.2.0
[0.1.5]: https://github.com/woylie/doggo/compare/0.1.4...0.1.5
[0.1.4]: https://github.com/woylie/doggo/compare/0.1.3...0.1.4
[0.1.3]: https://github.com/woylie/doggo/compare/0.1.2...0.1.3
[0.1.2]: https://github.com/woylie/doggo/compare/0.1.1...0.1.2
[0.1.1]: https://github.com/woylie/doggo/compare/0.1.0...0.1.1
[0.1.0]: https://github.com/woylie/doggo/releases/tag/0.1.0
