defmodule Doggo.AccessibilityTest do
  use ExUnit.Case, async: true

  alias Doggo.Accessibility

  defp parse(html), do: Floki.parse_fragment!(html)

  describe "names_on_nameless_elements/1" do
    test "rejects a name on a div or span with no role" do
      for tag <- ~w(div span), attr <- ~w(aria-label aria-labelledby) do
        assert_raise ExUnit.AssertionError, ~r/without a role/, fn ->
          Accessibility.names_on_nameless_elements(
            parse(~s(<#{tag} #{attr}="Name"></#{tag}>))
          )
        end
      end
    end

    test "accepts a name on a div with a role that permits one" do
      Accessibility.names_on_nameless_elements(
        parse(~s(<div role="group" aria-label="Name"></div>))
      )
    end

    test "accepts a div with no name" do
      Accessibility.names_on_nameless_elements(parse("<div></div>"))
    end
  end

  describe "nameless_interactive_elements/1" do
    test "rejects a button with nothing but a title" do
      assert_raise ExUnit.AssertionError, ~r/no accessible name/, fn ->
        Accessibility.nameless_interactive_elements(
          parse(~s(<button title="Edit"></button>))
        )
      end
    end

    test "rejects an unnamed link and an unlabelled input" do
      for html <- [~s(<a href="/pets"></a>), ~s(<input id="a" type="text">)] do
        assert_raise ExUnit.AssertionError, ~r/no accessible name/, fn ->
          Accessibility.nameless_interactive_elements(parse(html))
        end
      end
    end

    test "accepts every way of naming an interactive element" do
      for html <- [
            ~s(<button>Edit</button>),
            ~s(<button aria-label="Edit"></button>),
            ~s(<button aria-labelledby="x"></button>),
            ~s(<label for="a">Age</label><input id="a" type="text">),
            ~s(<label>Age<input type="text"></label>)
          ] do
        Accessibility.nameless_interactive_elements(parse(html))
      end
    end

    test "accepts an element hidden from assistive technology" do
      Accessibility.nameless_interactive_elements(
        parse(~s(<button aria-hidden="true" tabindex="-1"></button>))
      )
    end

    test "accepts a button named by an icon inside it" do
      Accessibility.nameless_interactive_elements(
        parse(~s(<button><svg aria-label="Edit"></svg></button>))
      )
    end
  end

  describe "expanded_state/1" do
    test "rejects a control that reports collapsed while its content shows" do
      assert_raise ExUnit.AssertionError, ~r/disagrees with/, fn ->
        Accessibility.expanded_state(
          parse(~s(<button aria-expanded="false" aria-controls="p"></button>
                   <div id="p">Content</div>))
        )
      end
    end

    test "rejects a control that reports expanded while its content is hidden" do
      assert_raise ExUnit.AssertionError, ~r/disagrees with/, fn ->
        Accessibility.expanded_state(
          parse(~s(<button aria-expanded="true" aria-controls="p"></button>
                   <div id="p" hidden>Content</div>))
        )
      end
    end

    test "accepts the two states that agree" do
      for {expanded, hidden} <- [{"true", ""}, {"false", "hidden"}] do
        Accessibility.expanded_state(
          parse(
            ~s(<button aria-expanded="#{expanded}" aria-controls="p"></button>
                   <div id="p" #{hidden}>Content</div>)
          )
        )
      end
    end

    test "ignores a control whose target is not in the document" do
      Accessibility.expanded_state(
        parse(
          ~s(<button aria-expanded="false" aria-controls="elsewhere"></button>)
        )
      )
    end
  end

  describe "duplicate_ids/1" do
    test "rejects the same id twice" do
      assert_raise ExUnit.AssertionError, ~r/more than once/, fn ->
        Accessibility.duplicate_ids(parse(~s(<i id="a"></i><b id="a"></b>)))
      end
    end

    test "accepts distinct ids" do
      Accessibility.duplicate_ids(parse(~s(<i id="a"></i><b id="b"></b>)))
    end
  end
end
