defmodule Doggo.Storybook.FrameBuilder do
  @moduledoc false

  def variations do
    # The frame component only becomes useful through the ratio modifier, which
    # is covered by the modifier variation groups.
    []
  end

  def modifier_variation(name, value) do
    %{
      attributes: %{name => value},
      slots: slots()
    }
  end

  defp slots do
    [
      """
      <img
        src="https://github.com/woylie/doggo/blob/main/assets/dog_poncho.jpg?raw=true"
        alt="A dog wearing a colorful poncho walks down a fashion show runway."
      />
      """
    ]
  end
end
