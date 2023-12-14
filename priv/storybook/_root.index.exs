defmodule Storybook.Root do
  # See https://hexdocs.pm/phoenix_storybook/PhoenixStorybook.Index.html for
  # full index documentation.

  use PhoenixStorybook.Index

  def folder_icon, do: {:fa, "book-open", :light, "lsb-mr-1"}
  def folder_name, do: "Storybook"
end
