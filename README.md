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
    {:doggo, "~> 0.12.0"}
  ]
end
```

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

Each modifier results in an additional attribute that is translated into a CSS
class. You can use the button defined above like this:

```html
<.button size="small">Edit</.button>
```

Most of the components have a base class that matches the component name.
By default, `Doggo.modifier_class_name/2` is used to build the CSS class name
for modifier attributes. The button above would be rendered with the class
`"button is-small"`.

You can override both the base class and the modifier class function:

```elixir
defmodule MyAppWeb.CoreComponents do
  use Doggo.Components
  use Phoenix.Component

  build_button(
    base_class: "alt-button",
    modifiers: [size: [values: ["normal", "small"], default: "normal"]]
  )

  def modifier_class(name, value) do
    "#{name}-#{value}"
  end
end
```

With these changes, the class would now be `"alt-button size-small`. To remove
the base class, just set it to `nil`.

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

If you use PurgeCSS, you can get a list of CSS class names of all configured
components:

```bash
mix dog.classes -m MyAppWeb.CoreComponents -o assets/modifiers.txt
```

Add the generated file to your PurgeCSS configuration.

## Design decisions

- Favor semantic HTML elements over CSS classes for structure and clarity.
- Adhere to accessibility guidelines with appropriate ARIA attributes and roles.
- Utilize semantic HTML and ARIA attributes for style bindings to states, rather
  than relying on CSS classes.
- Where state or variations can not be expressed semantically, use modifier
  classes named `.is-*` or `.has-*`.
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

Each component in the library is marked with one of four maturity levels.

- **Experimental**: These components are in the early development phase. They
  are incomplete, have unstable APIs, and are subject to significant changes.
  Not recommended for production use.
- **Developing**: Components at this stage have complete semantics, but
  interactivity features may still be missing. The API may still change based on
  feedback and testing. Suitable for internal testing and early feedback.
- **Refining**: Feature-complete components with a stable API, full
  configurability, and all required keyboard interactivity for accessibility
  implemented. The focus is on identifying and fixing remaining issues. Suitable
  for broader testing and cautious production use.
- **Stable**: Fully developed, tested, and ready for production use. These
  components have a stable API, are fully interactive, include a complete
  storybook module, and have exemplary CSS styles defined.

## Feedback

If you encounter any issues with a component, have suggestions for improvements,
or need a component for a specific use case that isn't currently available,
please don't hesitate to open a
[Github issue](https://github.com/woylie/doggo/issues).
