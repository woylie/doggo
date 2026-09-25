defmodule Doggo.Components.DatetimeTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Doggo.TestHelpers

  defmodule TestComponents do
    @moduledoc """
    Generates components for tests.
    """

    use Doggo.Components
    use Phoenix.Component

    build_datetime()
  end

  describe "datetime/1" do
    test "renders DateTime" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.datetime value={~U[2023-12-27T18:30:21Z]} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "2023-12-27T18:30:21Z"
      assert text(time) == "2023-12-27 18:30:21Z"
    end

    test "renders NaiveDateTime" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.datetime value={~N[2023-12-27 18:30:21]} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "2023-12-27T18:30:21"
      assert text(time) == "2023-12-27 18:30:21"
    end

    test "renders nothing for nil" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.datetime
          value={nil}
          formatter={& &1}
          title_formatter={& &1}
          precision={:minute}
          timezone="Asia/Tokyo"
        />
        """)

      assert html == []
    end

    test "formats text with formatter" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.datetime
          value={~N[2023-12-27 18:30:21]}
          formatter={&"#{&1.month}/#{&1.year} ~#{&1.hour}h"}
        />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "2023-12-27T18:30:21"
      assert text(time) == "12/2023 ~18h"
    end

    test "renders title with title formatter" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.datetime
          value={~N[2023-12-27 18:30:21]}
          title_formatter={&"#{&1.month}/#{&1.year} ~#{&1.hour}h"}
        />
        """)

      time = find_one(html, "time")

      assert attribute(time, "title") == "12/2023 ~18h"
    end

    test "renders DateTime with microsecond precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.datetime
          value={~U[2023-12-27T18:30:21.107074Z]}
          precision={:microsecond}
        />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "2023-12-27T18:30:21.107074Z"
      assert text(time) == "2023-12-27 18:30:21.107074Z"
    end

    test "renders DateTime with millisecond precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.datetime
          value={~U[2023-12-27T18:30:21.107074Z]}
          precision={:millisecond}
        />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "2023-12-27T18:30:21.107Z"
      assert text(time) == "2023-12-27 18:30:21.107Z"
    end

    test "renders DateTime with second precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.datetime
          value={~U[2023-12-27T18:30:21.107074Z]}
          precision={:second}
        />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "2023-12-27T18:30:21Z"
      assert text(time) == "2023-12-27 18:30:21Z"
    end

    test "renders DateTime with minute precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.datetime
          value={~U[2023-12-27T18:30:21.107074Z]}
          precision={:minute}
        />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "2023-12-27T18:30:00Z"
      assert text(time) == "2023-12-27 18:30:00Z"
    end

    test "renders NaiveDateTime with microsecond precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.datetime
          value={~N[2023-12-27T18:30:21.107074]}
          precision={:microsecond}
        />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "2023-12-27T18:30:21.107074"
      assert text(time) == "2023-12-27 18:30:21.107074"
    end

    test "renders NaiveDateTime with millisecond precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.datetime
          value={~N[2023-12-27T18:30:21.107074]}
          precision={:millisecond}
        />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "2023-12-27T18:30:21.107"
      assert text(time) == "2023-12-27 18:30:21.107"
    end

    test "renders NaiveDateTime with second precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.datetime
          value={~N[2023-12-27T18:30:21.107074]}
          precision={:second}
        />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "2023-12-27T18:30:21"
      assert text(time) == "2023-12-27 18:30:21"
    end

    test "renders NaiveDateTime with minute precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.datetime
          value={~N[2023-12-27T18:30:21.107074]}
          precision={:minute}
        />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "2023-12-27T18:30:00"
      assert text(time) == "2023-12-27 18:30:00"
    end

    test "shifts DateTime to time zone" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.datetime value={~U[2023-12-27T18:30:21Z]} timezone="Asia/Tokyo" />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "2023-12-28T03:30:21+09:00"
      assert text(time) == "2023-12-28 03:30:21+09:00 JST Asia/Tokyo"
    end
  end
end
