# Doggo

[![Hex](https://img.shields.io/hexpm/v/doggo)](https://hex.pm/packages/doggo) ![CI](https://github.com/woylie/doggo/workflows/CI/badge.svg) [![Coverage Status](https://coveralls.io/repos/github/woylie/doggo/badge.svg)](https://coveralls.io/github/woylie/doggo)

Headless UI component collection for Phoenix, focused on semantics and
accessibility.

For a full list of available components, please refer to the
[documentation](https://hexdocs.pm/doggo/Doggo.html).

## Installation

The package can be installed by adding `doggo` to your list of dependencies in
`mix.exs`:

```elixir
def deps do
  [
    {:doggo, "~> 0.14.9"}
  ]
end
```

### Compatibility

This package is tested against the Elixir and OTP versions that are still
supported upstream. Older versions down to the requirement in `mix.exs` may
still work, but they are not covered by CI and not officially supported.

## Usage

Use `Doggo.Components` in your core components module or in a separate module.
`Doggo.Components` defines macros that generate Phoenix components.

```elixir
defmodule MyAppWeb.CoreComponents do
  use Doggo.Components
  use Phoenix.Component

  build_alert()
  build_alert_dialog()

  build_button(
    modifiers: [
      size: [values: ["normal", "small"], default: "normal"]
    ]
  )
end
```

Each modifier results in an additional attribute that is translated into a
data attribute. You can use the button defined above like this:

```html
<.button size="small">Edit</.button>
```

The resulting HTML code will look similar to:

```html
<button data-size="small">Edit</button>
```

If no `type` option is set, a `string` attribute is added, but you can use any
attribute type, as long as the value can be converted to a string. Boolean
attributes result in a presence-only boolean data attribute.

```elixir
build_button(modifiers: [full_width: [type: :boolean]])
```

If the value is `true`, the attribute is added:

```html
<!-- code -->
<.button full_width>Edit</.button>

<!-- output -->
<button data-full-width>Edit</button>
```

If the attribute is omitted or the value is `false`, the attribute is omitted:

```html
<!-- code -->
<.button full_width={false}>Edit</.button>

<!-- output -->
<button>Edit</button>
```

Most of the components have a base class that matches the component name.

You can override the base class in the component options:

```elixir
defmodule MyAppWeb.CoreComponents do
  use Doggo.Components
  use Phoenix.Component

  build_button(
    base_class: "alt-button",
    modifiers: [size: [values: ["normal", "small"], default: "normal"]]
  )
end
```

To remove the base class, just set it to `nil`.

It is also possible to change the name of the generated component, which can be
useful if you want to compile multiple variants of the same component, or if
your design system uses different names.

```elixir
build_button(name: :alt_button, base_class: "alt-button")
```

This button could be used with:

```elixir
<.alt_button>Edit</.alt_button>
```

Refer to the `Doggo.Components` module documentation for more information about
the options and the individual components.

### Phoenix LiveView Hooks

Some components need a JavaScript hook. The hooks are ES modules shipped in the
`assets` directory of the package. Add it to your `package.json`:

```json
{
  "dependencies": {
    "@woylie/doggo": "file:../deps/doggo/assets"
  }
}
```

Then register the hooks for the components you build in your `app.js`:

```js
import {
  Accordion,
  Carousel,
  Menu,
  MenuButton,
  SplitPane,
  Tabs,
  Toolbar,
  Tooltip,
  Tree,
} from "@woylie/doggo";

const hooks = {
  "Doggo.Accordion": Accordion,
  "Doggo.Carousel": Carousel,
  "Doggo.Menu": Menu,
  "Doggo.MenuButton": MenuButton,
  "Doggo.SplitPane": SplitPane,
  "Doggo.Tabs": Tabs,
  "Doggo.Toolbar": Toolbar,
  "Doggo.Tooltip": Tooltip,
  "Doggo.Tree": Tree,
};

const liveSocket = new LiveSocket("/live", Socket, {
  // ...
  hooks,
});
```

It is recommended to only import the hooks you need to keep your bundle size
small.

To use the hooks in your storybook, register the same map in `storybook.js`:

```js
import {
  Accordion,
  Carousel,
  Menu,
  MenuButton,
  SplitPane,
  Tabs,
  Toolbar,
  Tooltip,
  Tree,
} from "@woylie/doggo";

(function () {
  window.storybook = {
    Hooks: {
      "Doggo.Accordion": Accordion,
      "Doggo.Carousel": Carousel,
      "Doggo.Menu": Menu,
      "Doggo.MenuButton": MenuButton,
      "Doggo.SplitPane": SplitPane,
      "Doggo.Tabs": Tabs,
      "Doggo.Toolbar": Toolbar,
      "Doggo.Tooltip": Tooltip,
      "Doggo.Tree": Tree,
    },
  };
})();
```

### Storybook

Doggo can generate
[Phoenix Storybook](https://hex.pm/packages/phoenix_storybook) stories for the
generated components. After you followed the installation instructions of
Phoenix Storybook, you can run a mix task to generate the stories:

```bash
mix dog.gen.stories -m MyAppWeb.CoreComponents -o storybook --all
```

Here, `MyAppWeb.CoreComponents` is the module in which you added
`use Doggo.Components`, and `storybook` is the path to the storybook folder.

The task will only generate story modules for the components that you
configured. The stories will include variations for all configured modifiers.

You don't need to update the stories after changing the modifiers of a
component. However, you'll need to run the task again after adding new
components to your module, or potentially after a new Doggo version was
released.

The task will ask for confirmation to overwrite existing stories. To only
write the story for a single component, you can run:

```bash
mix dog.gen.stories -m MyAppWeb.CoreComponents -o storybook -c button
```

### PurgeCSS

You can generate a safelist with the CSS classes and data attributes of all
configured components with:

```bash
mix dog.safelist -m MyAppWeb.CoreComponents -o assets/doggo_safelist.txt
```

### Visually hidden text

Several components render text that is meant to be available to screen readers
but not shown on screen, and they mark it with the `data-visually-hidden`
attribute. The library ships no CSS, so you have to define the rule yourself.

```css
[data-visually-hidden] {
  position: absolute;
  width: 1px;
  height: 1px;
  overflow: hidden;
  white-space: nowrap;
  clip-path: inset(50%);
}
```

Do not use `display: none` or `visibility: hidden` here. Both remove the element
from the accessibility tree, so the text is hidden from screen readers as well,
which is the opposite of what the attribute is for. The page looks correct while
the icon has lost its description and the field has lost its label.

### Field error announcements

The `field` component always renders its error list, even when the field has no
errors, because a live region that is added to the page at the same time as its
content is not reliably announced. The element has to be there first, so it
cannot be conditional.

Depending on your styles, an empty `.field-errors` element can cause a visual
gap. To take it out of the flow without taking it out of the accessibility tree:

```css
.field:not([data-invalid]) .field-errors {
  position: absolute;
  width: 1px;
  height: 1px;
  overflow: hidden;
  white-space: nowrap;
  clip-path: inset(50%);
}
```

Do not use `display: none` or `visibility: hidden` here. Both remove the element
from the accessibility tree, so an error that appears later is not announced,
which is the whole reason the list is rendered up front.

The `data-invalid` attribute is set on the field wrapper whenever the field has
errors. The `:empty` selector does not work here, because the rendered list
contains whitespace.

## Design decisions

- Favor semantic HTML elements over CSS classes for structure and clarity.
- Adhere to accessibility guidelines with appropriate ARIA attributes and roles.
- Utilize semantic HTML and ARIA attributes for style bindings to states, rather
  than relying on CSS classes.
- Where state or variations cannot be expressed semantically, use data
  attributes.
- The library is designed without default styles and does not prefer any
  particular CSS framework.

## Demo app

The repository contains a demo application that renders a storybook with all
components using their default options. For some of the components, CSS was
added, while others are still unstyled.

The demo application is deployed at: https://doggo.wlyx.dev

To run the application locally:

```bash
git clone git@github.com:woylie/doggo.git
cd doggo/demo
mix setup
mix phx.server
```

The storybook can be accessed at http://localhost:4000.

## Status

The library is actively developed. Being in its early stages, the library may
still undergo significant changes, including potential breaking changes.

### Maturity Levels

Each component is marked with one of four maturity levels.

- **Experimental**: In early development. Incomplete, with an unstable API, and
  subject to significant change. Not recommended for production use.
- **Developing**: Complete semantics, but interactivity may still be missing.
  The API may still change based on feedback and testing. Suitable for internal
  testing and early feedback.
- **Refining**: Feature-complete, with a stable API, full configurability, and
  all keyboard interactivity required for accessibility. The focus is on finding
  and fixing remaining issues. Suitable for broader testing and cautious
  production use.
- **Stable**: Fully developed, tested, and ready for production use. A stable
  API, fully interactive, a complete storybook module, and exemplary CSS styles
  defined.

### What counts as a breaking change

The markup a component renders is part of its API. You write your styles against
that markup, so a change to it can break your application just as surely
as a renamed attribute, and it is versioned accordingly.

Stability is declared per component, not per release. Which release a
breaking change can appear in depends on the maturity level of the component it
affects:

- **Experimental** and **Developing** components may change in a **patch**
  release, including in ways that break you.
- **Refining** and **Stable** components get a **minor** release for a breaking
  change while the library is pre 1.0, with the change named in the changelog.

These changes are **not** breaking, and can appear in a patch release for a
component at any level:

- Adding an attribute.
- Adding a class.
- Removing an attribute that normally no CSS styles are attached to.

These changes **are** breaking:

- Removing or renaming an `aria-*` or `data-*` attribute, since you may have
  attached styles to it.
- Removing or renaming a class.
- Adding or removing nesting, since it changes which descendant and child
  selectors match.
- Changing an element type.
- Reordering elements.

## Feedback

If you encounter any issues with a component, have suggestions for improvements,
or need a component for a specific use case that isn't currently available,
please don't hesitate to open a
[Github issue](https://github.com/woylie/doggo/issues).
