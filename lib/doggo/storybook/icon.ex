defmodule Doggo.Storybook.Icon do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation
  alias PhoenixStorybook.Stories.VariationGroup

  def variations(opts) do
    [first_name | _] = names = get_names(opts)

    [
      %Variation{
        id: :default,
        attributes: %{name: first_name}
      },
      %VariationGroup{
        id: :text_ltr,
        description: "With text (ltr)",
        variations: [
          %Variation{
            id: :after,
            attributes: %{
              name: first_name,
              text: "text after icon",
              text_position: "after"
            }
          },
          %Variation{
            id: :before,
            attributes: %{
              name: first_name,
              text: "text before icon",
              text_position: "before"
            }
          },
          %Variation{
            id: :hidden,
            attributes: %{
              name: first_name,
              text: "text hidden",
              text_position: "hidden"
            }
          }
        ]
      },
      %VariationGroup{
        id: :text_rtl,
        description: "With text (rtl)",
        variations: [
          %Variation{
            id: :after,
            attributes: %{
              name: first_name,
              text: "متن بعد از نماد",
              text_position: "after"
            }
          },
          %Variation{
            id: :before,
            attributes: %{
              name: first_name,
              text: "متن قبل از نماد",
              text_position: "before"
            }
          },
          %Variation{
            id: :hidden,
            attributes: %{
              name: first_name,
              text: "متن مخفی",
              text_position: "hidden"
            }
          }
        ],
        template: """
        <div dir="rtl">
          <.psb-variation />
        </div>
        """
      },
      %VariationGroup{
        id: :names,
        variations:
          for name <- names do
            %Variation{
              id: :"name_#{name}",
              attributes: %{
                name: first_name
              }
            }
          end
      }
    ]
  end

  def modifier_variation_base(_id, _name, _value, opts) do
    [first_name | _] = get_names(opts)

    %{
      attributes: %{name: first_name}
    }
  end

  defp get_names(opts) do
    names = opts |> Keyword.get(:extra, []) |> Keyword.get(:names, [])

    names =
      case names do
        names when is_list(names) -> names
        fun when is_function(fun) -> fun.()
      end

    if names == [] do
      raise """
      no names configured

      To render a preview for the icon component, you need to pass a list of
      icon names as a build option.

          build_icon(icon_module: MyIcons, names: ["info", "question-mark"])

      It is also possible to pass a function that returns such a list.

          build_icon(icon_module: MyIcons, names: &MyIcons.names/0)

      The list of names is only used in the storybook and does not have to be
      comprehensive.
      """
    end

    names
  end
end
