defmodule Doggo.Components.TimeTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Doggo.TestHelpers

  defmodule TestComponents do
    @moduledoc """
    Generates components for tests.
    """

    use Doggo.Components
    use Phoenix.Component

    build_time()
  end

  describe "time/1" do
    test "renders time" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.time value={~T[18:30:21]} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "18:30:21"
      assert text(time) == "18:30:21"
    end

    test "renders time of DateTime" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.time value={~U[2023-12-27T18:30:21Z]} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "18:30:21"
      assert text(time) == "18:30:21"
    end

    test "renders time of NaiveDateTime" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.time value={~N[2023-12-27 18:30:21]} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "18:30:21"
      assert text(time) == "18:30:21"
    end

    test "renders nothing for nil" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.time
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
        <TestComponents.time
          value={~T[18:30:21]}
          formatter={&"#{&1.hour}h #{&1.minute}m"}
        />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "18:30:21"
      assert text(time) == "18h 30m"
    end

    test "renders title with title formatter" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.time
          value={~T[18:30:21]}
          title_formatter={&"#{&1.hour}h #{&1.minute}m"}
        />
        """)

      assert attribute(html, "time", "title") == "18h 30m"
    end

    test "renders Time with microsecond precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.time value={~T[18:30:21.107074]} precision={:microsecond} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "18:30:21.107074"
      assert text(time) == "18:30:21.107074"
    end

    test "renders Time with millisecond precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.time value={~T[18:30:21.107074]} precision={:millisecond} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "18:30:21.107"
      assert text(time) == "18:30:21.107"
    end

    test "renders Time with second precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.time value={~T[18:30:21.107074]} precision={:second} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "18:30:21"
      assert text(time) == "18:30:21"
    end

    test "renders Time with minute precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.time value={~T[18:30:21.107074]} precision={:minute} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "18:30:00"
      assert text(time) == "18:30:00"
    end

    test "renders DateTime with microsecond precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.time
          value={~U[2023-12-27T18:30:21.107074Z]}
          precision={:microsecond}
        />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "18:30:21.107074"
      assert text(time) == "18:30:21.107074"
    end

    test "renders DateTime with millisecond precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.time
          value={~U[2023-12-27T18:30:21.107074Z]}
          precision={:millisecond}
        />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "18:30:21.107"
      assert text(time) == "18:30:21.107"
    end

    test "renders DateTime with second precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.time
          value={~U[2023-12-27T18:30:21.107074Z]}
          precision={:second}
        />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "18:30:21"
      assert text(time) == "18:30:21"
    end

    test "renders DateTime with minute precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.time
          value={~U[2023-12-27T18:30:21.107074Z]}
          precision={:minute}
        />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "18:30:00"
      assert text(time) == "18:30:00"
    end

    test "renders NaiveDateTime with microsecond precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.time
          value={~N[2023-12-27T18:30:21.107074]}
          precision={:microsecond}
        />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "18:30:21.107074"
      assert text(time) == "18:30:21.107074"
    end

    test "renders NaiveDateTime with millisecond precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.time
          value={~N[2023-12-27T18:30:21.107074]}
          precision={:millisecond}
        />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "18:30:21.107"
      assert text(time) == "18:30:21.107"
    end

    test "renders NaiveDateTime with second precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.time value={~N[2023-12-27T18:30:21.107074]} precision={:second} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "18:30:21"
      assert text(time) == "18:30:21"
    end

    test "renders NaiveDateTime with minute precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.time value={~N[2023-12-27T18:30:21.107074]} precision={:minute} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "18:30:00"
      assert text(time) == "18:30:00"
    end

    test "shifts DateTime to time zone" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.time value={~U[2023-12-27T18:30:21Z]} timezone="Asia/Tokyo" />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "03:30:21"
      assert text(time) == "03:30:21"
    end
  end
end
