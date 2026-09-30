defmodule Doggo.Components.DateTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Doggo.TestHelpers

  defmodule TestComponents do
    @moduledoc """
    Generates components for tests.
    """

    use Doggo.Components
    use Phoenix.Component

    build_date()
  end

  describe "date/1" do
    test "renders date" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.date value={~D[2023-12-27]} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "2023-12-27"
      assert text(time) == "2023-12-27"
    end

    test "renders date of DateTime" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.date value={~U[2023-12-27T18:30:21Z]} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "2023-12-27"
      assert text(time) == "2023-12-27"
    end

    test "renders date of NaiveDateTime" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.date value={~N[2023-12-27T18:30:21]} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "2023-12-27"
      assert text(time) == "2023-12-27"
    end

    test "renders nothing for nil" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.date
          value={nil}
          formatter={& &1}
          title_formatter={& &1}
          timezone="Asia/Tokyo"
        />
        """)

      assert html == []
    end

    test "formats text with formatter" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.date
          value={~N[2023-12-27 18:30:21]}
          formatter={&"#{&1.year}/#{&1.month}/#{&1.day}"}
        />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "2023-12-27"
      assert text(time) == "2023/12/27"
    end

    test "renders title with title formatter" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.date
          value={~N[2023-12-27 18:30:21]}
          title_formatter={&"#{&1.year}/#{&1.month}/#{&1.day}"}
        />
        """)

      time = find_one(html, "time")

      assert attribute(time, "title") == "2023/12/27"
      assert text(time) == "2023-12-27"
    end

    test "shifts DateTime to time zone" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.date value={~U[2023-12-27T18:30:21Z]} timezone="Asia/Tokyo" />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "2023-12-28"
      assert text(time) == "2023-12-28"
    end

    test "omits datetime attribute for year before 1" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.date value={Date.new!(-5, 1, 1)} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == nil
      assert text(time) == "-0005-01-01"
    end

    test "raises for Time" do
      assigns = %{}

      assert_raise ArgumentError,
                   ~r/invalid value for \.date.*Use \.time for a Time/s,
                   fn ->
                     parse_heex(~H"""
                     <TestComponents.date value={~T[18:30:21]} />
                     """)
                   end
    end

    test "raises for invalid title formatter" do
      assigns = %{}

      assert_raise ArgumentError,
                   ~r/invalid title_formatter value for \.date/,
                   fn ->
                     parse_heex(~H"""
                     <TestComponents.date value={~D[2023-12-27]} title_formatter="x" />
                     """)
                   end
    end
  end
end
