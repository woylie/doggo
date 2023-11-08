# Doggo

Collection of Phoenix components with semantic CSS classes. No CSS styles
included at the moment.

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

## Design decision

- Favor semantic HTML elements over CSS classes for structure and clarity.
- Adhere to accessibility guidelines with appropriate ARIA attributes and roles.
- Utilize semantic HTML and ARIA attributes for style bindings to states, rather
  than relying on CSS classes.
- Where state or variations can not be expressed semantically, use modifier
  classes named `.is-*` or `.has-*`.
- Provide a base CSS class for each component to support unstyled or
  alternatively styled variations of the same HTML elements.
- Prefix CSS class names with a library-specific shorthand (`dg-`) to avoid
  conflicts and aid in recognition.
- The library is designed without default styles and does not prefer any
  particular CSS framework.
