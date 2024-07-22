defmodule Doggo.Storybook.Skeleton do
  @moduledoc false

  def variations(_opts) do
    # The skeleton component only becomes useful through the type modifier,
    # which is covered by the modifier variation groups.
    []
  end

  def modifier_variation_base(_id, _name, _value, _opts) do
    %{}
  end
end
