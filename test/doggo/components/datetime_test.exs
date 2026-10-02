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

      assert attribute(time, "datetime") == "2023-12-27T18:30:21.107Z"
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

      assert attribute(time, "datetime") == "2023-12-27T18:30Z"
      assert text(time) == "2023-12-27 18:30Z"
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

      assert attribute(time, "datetime") == "2023-12-27T18:30:21.107"
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

      assert attribute(time, "datetime") == "2023-12-27T18:30"
      assert text(time) == "2023-12-27 18:30"
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

    test "encodes datetime attribute as in the HTML examples" do
      assigns = %{
        values: [
          {~N[2011-11-18 14:54:39.929], "2011-11-18T14:54:39.929"},
          {~U[2011-11-18 14:54:39.929Z], "2011-11-18T14:54:39.929Z"},
          {DateTime.shift_zone!(
             ~U[2011-11-18 18:54:39.929Z],
             "America/Halifax"
           ), "2011-11-18T14:54:39.929-04:00"},
          {DateTime.shift_zone!(~U[2011-11-18 09:09:39.929Z], "Asia/Kathmandu"),
           "2011-11-18T14:54:39.929+05:45"}
        ]
      }

      html =
        parse_heex(~H"""
        <TestComponents.datetime :for={{value, _} <- @values} value={value} />
        """)

      assert Enum.map(Floki.find(html, "time"), &attribute(&1, "datetime")) ==
               Enum.map(assigns.values, &elem(&1, 1))
    end

    test "encodes offset with seconds in UTC" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.datetime value={~U[1880-01-01 00:00:00Z]} timezone="Asia/Tokyo" />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == "1880-01-01T00:00:00Z"
      assert text(time) == "1880-01-01 09:18:59+09:18 LMT Asia/Tokyo"
    end

    test "omits datetime attribute for year before 1" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.datetime value={~N[0000-12-31 18:30:21]} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "datetime") == nil
      assert text(time) == "0000-12-31 18:30:21"
    end

    test "raises for Date" do
      assigns = %{}

      assert_raise ArgumentError,
                   ~r/invalid value for \.datetime.*Use \.date for a Date/s,
                   fn ->
                     parse_heex(~H"""
                     <TestComponents.datetime value={~D[2023-12-27]} />
                     """)
                   end
    end

    test "raises for invalid formatter" do
      assigns = %{}

      assert_raise ArgumentError,
                   ~r/invalid formatter value for \.datetime/,
                   fn ->
                     parse_heex(~H"""
                     <TestComponents.datetime
                       value={~N[2023-12-27 18:30:21]}
                       formatter="short"
                     />
                     """)
                   end
    end

    test "raises for invalid precision" do
      assigns = %{precision: :hour}

      assert_raise ArgumentError,
                   ~r/invalid precision for \.datetime.*:hour/s,
                   fn ->
                     parse_heex(~H"""
                     <TestComponents.datetime value={~N[2023-12-27 18:30:21]} precision={@precision} />
                     """)
                   end
    end

    test "renders localize attributes" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.datetime value={~U[2023-12-27T18:30:21Z]} localize />
        """)

      time = find_one(html, "time")

      assert attribute(time, "data-localize") == "datetime"
      assert attribute(time, "translate") == "no"
      assert attribute(time, "data-localize-zone") == nil
      assert attribute(time, "data-localize-title") == nil
      assert text(time) == "2023-12-27 18:30:21Z"
    end

    test "renders localize style, options, zone and title" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.datetime
          value={~U[2023-12-27T18:30:21Z]}
          timezone="Asia/Tokyo"
          localize={[weekday: :short, hour_cycle: :h23, zone: :server, title: :full]}
        />
        """)

      time = find_one(html, "time")

      assert attribute(time, "data-localize-weekday") == "short"
      assert attribute(time, "data-localize-hour-cycle") == "h23"
      assert attribute(time, "data-localize-zone") == "server"
      assert attribute(time, "data-timezone") == "Asia/Tokyo"
      assert attribute(time, "data-localize-title") == "full"
      assert attribute(time, "title") == nil
    end

    test "renders localize title pattern as server title" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.datetime
          value={~U[2023-12-27T18:30:21Z]}
          localize={[style: :short, title: "%Y-%m-%d %H:%M"]}
        />
        """)

      time = find_one(html, "time")

      assert attribute(time, "data-localize-title") == "%Y-%m-%d %H:%M"
      assert attribute(time, "title") == "2023-12-27 18:30"
    end

    test "renders title formatter instead of localize title pattern" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.datetime
          value={~U[2023-12-27T18:30:21Z]}
          title_formatter={fn _ -> "custom" end}
          localize={[style: :short, title: "%Y-%m-%d"]}
        />
        """)

      assert attribute(html, "time", "title") == "custom"
    end

    test "renders localize style with hour cycle" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.datetime
          value={~U[2023-12-27T18:30:21Z]}
          localize={[style: :medium, hour_cycle: :h23]}
        />
        """)

      time = find_one(html, "time")

      assert attribute(time, "data-localize-style") == "medium"
      assert attribute(time, "data-localize-hour-cycle") == "h23"
    end

    test "renders localize pattern as server text" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.datetime
          value={~U[2023-12-27T18:30:21Z]}
          timezone="Asia/Tokyo"
          localize="%Y-%m-%d %H:%M"
        />
        """)

      time = find_one(html, "time")

      assert attribute(time, "data-localize-pattern") == "%Y-%m-%d %H:%M"
      assert text(time) == "2023-12-28 03:30"
    end

    test "renders formatter instead of localize pattern" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.datetime
          value={~U[2023-12-27T18:30:21Z]}
          localize="%Y-%m-%d"
          formatter={fn _ -> "custom" end}
        />
        """)

      assert text(html, "time") == "custom"
    end

    test "renders no localize attributes with localize false" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.datetime value={~U[2023-12-27T18:30:21Z]} localize={false} />
        """)

      time = find_one(html, "time")

      assert attribute(time, "data-localize") == nil
      assert attribute(time, "translate") == nil
    end

    test "raises for localize title pattern with unsupported directive" do
      assigns = %{}

      assert_raise ArgumentError,
                   ~r/invalid localize pattern for \.datetime.*%b/s,
                   fn ->
                     parse_heex(~H"""
                     <TestComponents.datetime
                       value={~U[2023-12-27T18:30:21Z]}
                       localize={[style: :short, title: "%d %b"]}
                     />
                     """)
                   end
    end

    test "raises for localize pattern with unsupported directive" do
      assigns = %{}

      assert_raise ArgumentError,
                   ~r/invalid localize pattern for \.datetime.*%b/s,
                   fn ->
                     parse_heex(~H"""
                     <TestComponents.datetime value={~U[2023-12-27T18:30:21Z]} localize="%d %b" />
                     """)
                   end
    end

    test "raises for invalid localize value" do
      for localize <- [
            :tiny,
            [style: :medium, weekday: :short],
            [zone: 1],
            [colour: :red],
            [pattern: 1],
            [title: :tiny]
          ] do
        assigns = %{localize: localize}

        assert_raise ArgumentError,
                     ~r/invalid localize value for \.datetime/,
                     fn ->
                       parse_heex(~H"""
                       <TestComponents.datetime value={~U[2023-12-27T18:30:21Z]} localize={@localize} />
                       """)
                     end
      end
    end
  end
end
