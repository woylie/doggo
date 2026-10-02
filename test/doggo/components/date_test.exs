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

      assert attribute(time, "datetime") == "2023-12-27T18:30:21Z"
      assert text(time) == "2023-12-27"
    end

    test "renders date of NaiveDateTime" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.date value={~N[2023-12-27T18:30:21]} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "2023-12-27T18:30:21"
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

      assert attribute(time, "datetime") == "2023-12-27T18:30:21"
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

      assert attribute(time, "datetime") == "2023-12-28T03:30:21+09:00"
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

    test "renders year for year precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.date value={~D[1980-05-17]} precision={:year} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "1980"
      assert text(time) == "1980"
    end

    test "renders month for month precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.date value={~D[1980-05-17]} precision={:month} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "1980-05"
      assert text(time) == "1980-05"
    end

    test "renders yearless date for month_day precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.date value={~D[1980-05-17]} precision={:month_day} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "05-17"
      assert text(time) == "05-17"
    end

    test "renders date for day precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.date value={~U[1980-05-17T18:30:21Z]} precision={:day} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "1980-05-17"
      assert text(time) == "1980-05-17"
    end

    test "renders yearless date for year before 1" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.date value={Date.new!(-5, 5, 17)} precision={:month_day} />
        """)

      assert attribute(html, "time", "datetime") == "05-17"
    end

    test "passes full date to formatter with precision" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.date
          value={~D[1980-05-17]}
          precision={:year}
          formatter={&to_string(&1.day)}
        />
        """)

      assert text(html, "time") == "17"
    end

    test "raises for invalid precision" do
      assigns = %{precision: :hour}

      assert_raise ArgumentError,
                   ~r/invalid precision for \.date.*:hour/s,
                   fn ->
                     parse_heex(~H"""
                     <TestComponents.date value={~D[1980-05-17]} precision={@precision} />
                     """)
                   end
    end

    test "renders localize attributes" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.date value={~D[2023-12-27]} localize={:long} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "data-localize") == "date"
      assert attribute(time, "data-localize-style") == "long"
    end

    test "raises for localize list that is not a keyword list" do
      assigns = %{}

      assert_raise ArgumentError, ~r/invalid localize value for \.date/, fn ->
        parse_heex(~H"""
        <TestComponents.date value={~D[2023-12-27]} localize={[:long]} />
        """)
      end
    end

    test "raises for localize value of another type" do
      assigns = %{}

      assert_raise ArgumentError, ~r/invalid localize value for \.date/, fn ->
        parse_heex(~H"""
        <TestComponents.date value={~D[2023-12-27]} localize={42} />
        """)
      end
    end

    test "raises for localize pattern with time directive" do
      assigns = %{}

      assert_raise ArgumentError, ~r/invalid localize pattern for \.date/, fn ->
        parse_heex(~H"""
        <TestComponents.date value={~D[2023-12-27]} localize="%Y %H" />
        """)
      end
    end
  end
end
