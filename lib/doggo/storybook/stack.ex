defmodule Doggo.Storybook.Stack do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def variations(_opts) do
    [
      %Variation{
        id: :default,
        description: "Default (margin only applied to direct children)",
        slots: slots()
      },
      %Variation{
        id: :recursive,
        description: "Recursive (margin applied to nested children)",
        attributes: %{recursive: true},
        slots: recursive_slots()
      }
    ]
  end

  def modifier_variation_base(_id, _name, _value, _opts) do
    %{
      slots: slots()
    }
  end

  defp slots do
    [
      """
      <p>
        Dogs bring joy and companionship to our lives. Their loyalty and
        playful nature make them cherished pets in many households.
      </p>
      <p>
        Training a dog requires patience and consistency. Using positive
        reinforcement, like treats and praise, helps in teaching commands
        effectively.
      </p>
      <p>
        Different breeds have unique traits. For example, Labradors are known
        for their friendliness, while Border Collies are celebrated for their
        intelligence.
      </p>
      """
    ]
  end

  defp recursive_slots do
    [
      """
      <section>
        <h3>Training</h3>
        <p>
          Training a dog requires patience and consistency. Using positive
          reinforcement, like treats and praise, helps in teaching commands
          effectively.
        </p>
      </section>
      <p>
        Different breeds have unique traits. For example, Labradors are known
        for their friendliness, while Border Collies are celebrated for their
        intelligence.
      </p>
      """
    ]
  end
end
