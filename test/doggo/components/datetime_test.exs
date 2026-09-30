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
  end
end
