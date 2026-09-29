defmodule Doggo.Components.BoxTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Doggo.TestHelpers

  defmodule TestComponents do
    @moduledoc """
    Generates components for tests.
    """

    use Doggo.Components
    use Phoenix.Component

    build_box()
  end

  describe "box/1" do
    test "renders box" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.box>
          Content
        </TestComponents.box>
        """)

      section = find_one(html, "section:root")
      assert attribute(section, "class") == "box"
      assert attribute(section, "aria-labelledby") == nil
      body = find_one(section, ".box-body")
      assert text(body) == "Content"
    end

    test "renders title in heading" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.box>
          <:title>Profile</:title>
        </TestComponents.box>
        """)

      assert text(html, "section:root > header > h2") == "Profile"
    end

    test "renders title in heading with heading level" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.box heading="h3">
          <:title>Profile</:title>
        </TestComponents.box>
        """)

      assert text(html, "section:root > header > h3") == "Profile"
    end

    test "derives title and body ids with id" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.box id="profile" aria-labelledby="profile-title">
          <:title>Profile</:title>
          Content
        </TestComponents.box>
        """)

      assert attribute(html, "section:root", "id") == "profile"

      assert attribute(html, "section:root", "aria-labelledby") ==
               "profile-title"

      assert attribute(html, "section:root > header > h2", "id") ==
               "profile-title"

      assert attribute(html, ".box-body", "id") == "profile-body"
    end

    test "renders no ids without id" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.box>
          <:title>Profile</:title>
          Content
        </TestComponents.box>
        """)

      assert attribute(html, "section:root", "id") == nil
      assert attribute(html, "section:root > header > h2", "id") == nil
      assert attribute(html, ".box-body", "id") == nil
    end

    test "renders banner" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.box>
          <:banner>Banner</:banner>
        </TestComponents.box>
        """)

      assert text(html, "section:root > header > div.box-banner") == "Banner"
    end

    test "renders action" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.box>
          <:action>Action</:action>
        </TestComponents.box>
        """)

      assert text(html, "section:root > header > div.box-actions") == "Action"
    end

    test "renders footer" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.box>
          <:footer>Doggo</:footer>
        </TestComponents.box>
        """)

      assert text(html, "section:root > footer") == "Doggo"
    end

    test "renders global attributes" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.box data-test="hello"></TestComponents.box>
        """)

      assert attribute(html, "section:root", "data-test") == "hello"
    end
  end
end
