# Used by "mix format"
[
  plugins: [Phoenix.LiveView.HTMLFormatter],
  import_deps: [:phoenix, :phoenix_live_view],
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{heex, ex,exs}"],
  line_length: 80
]
