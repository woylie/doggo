defmodule Doggo.Components.RelativeTimeTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Doggo.TestHelpers

  defmodule TestComponents do
    @moduledoc """
    Generates components for tests.
    """

    use Doggo.Components
    use Phoenix.Component

    build_relative_time()
  end

  describe "relative_time/1" do
    test "renders DateTime in UTC with the absolute value as text" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.relative_time value={~U[2023-12-27T18:30:21.107074Z]} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "class") == "relative-time"
      assert attribute(time, "datetime") == "2023-12-27T18:30:21.107Z"
      assert attribute(time, "data-relative") == "datetime"
      assert attribute(time, "dir") == "auto"
      assert attribute(time, "translate") == "no"
      assert attribute(time, "data-relative-sync") == nil
      assert text(time) == "2023-12-27 18:30:21.107074Z"
    end

    test "renders DateTime shifted to time zone as text" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.relative_time
          value={~U[2023-12-27T18:30:21Z]}
          timezone="Asia/Tokyo"
        />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "2023-12-27T18:30:21Z"
      assert text(time) == "2023-12-28 03:30:21+09:00 JST Asia/Tokyo"
    end

    test "renders Date" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.relative_time value={~D[2023-12-27]} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "2023-12-27"
      assert attribute(time, "data-relative") == "date"
    end

    test "renders options" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.relative_time
          value={~U[2023-12-27T18:30:21Z]}
          format={:short}
          numeric={:always}
          sync
          tense={:past}
          threshold={86_400}
          now={~U[2023-12-28T18:30:21Z]}
          localize={:medium}
        />
        """)

      time = find_one(html, "time")

      assert attribute(time, "data-relative-format") == "short"
      assert attribute(time, "data-relative-numeric") == "always"
      assert attribute(time, "data-relative-sync") == "true"
      assert attribute(time, "data-relative-tense") == "past"
      assert attribute(time, "data-relative-threshold") == "86400"
      assert attribute(time, "data-relative-now") == "2023-12-28T18:30:21Z"
      assert attribute(time, "data-localize") == "datetime"
      assert attribute(time, "data-localize-style") == "medium"
    end

    test "renders nothing for nil" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.relative_time value={nil} />
        """)

      assert html == []
    end

    test "raises for NaiveDateTime" do
      assigns = %{}

      assert_raise ArgumentError,
                   ~r/invalid value for \.relative_time.*DateTime.from_naive!/s,
                   fn ->
                     parse_heex(~H"""
                     <TestComponents.relative_time value={~N[2023-12-27 18:30:21]} />
                     """)
                   end
    end

    test "renders Duration threshold in seconds" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.relative_time
          value={~D[2023-12-27]}
          threshold={Duration.new!(day: 1, hour: 2)}
        />
        """)

      assert attribute(html, "time", "data-relative-threshold") == "93600"
    end

    test "raises for invalid threshold" do
      assigns = %{}

      assert_raise ArgumentError,
                   ~r/invalid threshold value for \.relative_time/,
                   fn ->
                     parse_heex(~H"""
                     <TestComponents.relative_time
                       value={~D[2023-12-27]}
                       threshold={Duration.new!(month: 1)}
                     />
                     """)
                   end
    end

    test "raises for negative Duration threshold" do
      assigns = %{}

      assert_raise ArgumentError,
                   ~r/invalid threshold value for \.relative_time/,
                   fn ->
                     parse_heex(~H"""
                     <TestComponents.relative_time
                       value={~D[2023-12-27]}
                       threshold={Duration.new!(day: -1)}
                     />
                     """)
                   end
    end

    test "raises for invalid now" do
      assigns = %{}

      assert_raise ArgumentError,
                   ~r/invalid now value for \.relative_time/,
                   fn ->
                     parse_heex(~H"""
                     <TestComponents.relative_time value={~D[2023-12-27]} now={~D[2023-12-27]} />
                     """)
                   end
    end
  end
end
