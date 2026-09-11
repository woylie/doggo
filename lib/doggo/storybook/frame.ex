defmodule Doggo.Storybook.Frame do
  @moduledoc false

  def variations(_opts) do
    # The frame component only becomes useful through the ratio modifier, which
    # is covered by the modifier variation groups.
    []
  end

  def modifier_variation_base(_id, _name, _value, _opts) do
    %{
      slots: slots()
    }
  end

  defp slots do
    [
      """
      <img
        src="https://github.com/woylie/doggo/blob/main/assets/images/dog_1.webp?raw=true"
        alt="A gray-muzzled dog in a camouflage coat and harness."
      />
      """
    ]
  end
end
