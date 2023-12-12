# Doggo

Collection of unstyled Phoenix components with semantic CSS classes.

## Installation

The package can be installed by adding `doggo` to your list of dependencies in
`mix.exs`:

```elixir
def deps do
  [
    {:doggo, github: "woylie/doggo", branch: "main"}
  ]
end
```

To allow Doggo to translate certain strings such as form field errors with
Gettext, set your Gettext module in `config/config.exs`:

    config :doggo, gettext: MyApp.Gettext

## Design decisions

- Favor semantic HTML elements over CSS classes for structure and clarity.
- Adhere to accessibility guidelines with appropriate ARIA attributes and roles.
- Utilize semantic HTML and ARIA attributes for style bindings to states, rather
  than relying on CSS classes.
- Where state or variations can not be expressed semantically, use modifier
  classes named `.is-*` or `.has-*`.
- Provide a base CSS class for each component to support unstyled or
  alternatively styled variations of the same HTML elements.
- The library is designed without default styles and does not prefer any
  particular CSS framework.

## Status

The library is actively developed. Being in its early stages, the library may
still undergo significant changes, potentially leading to breaking changes.
