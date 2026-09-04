defmodule DemoWeb.PatchTestLiveTest do
  use DemoWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "renders the harness with all six components", %{conn: conn} do
    {:ok, live, html} = live(conn, ~p"/patch-test")

    assert html =~ "LiveView patch test"

    for id <- ~w(test-modal test-alert-dialog test-tabs test-accordion
                 test-disclosure) do
      assert html =~ id
    end

    assert has_element?(live, "button[aria-pressed]")
  end

  test "bump increments the tick", %{conn: conn} do
    {:ok, live, _html} = live(conn, ~p"/patch-test")

    assert live |> element("#tick") |> render() =~ ">0<"

    live |> element("#bump") |> render_click()
    assert live |> element("#tick") |> render() =~ ">1<"
  end

  test "the round trip changes no assigns", %{conn: conn} do
    {:ok, live, _html} = live(conn, ~p"/patch-test")

    live |> element("#bump") |> render_click()
    before = render(live)

    live |> element("#round-trip") |> render_click()
    assert render(live) == before
  end

  test "the components can be wrapped in a comprehension", %{conn: conn} do
    {:ok, live, html} = live(conn, ~p"/patch-test")
    assert html =~ "wrapped false"
    assert has_element?(live, "#resend[disabled]")

    html = live |> element("#toggle-wrap") |> render_click()
    assert html =~ "wrapped true"
    refute has_element?(live, "#resend[disabled]")
  end

  test "re-sending changes the comprehension only", %{conn: conn} do
    {:ok, live, _html} = live(conn, ~p"/patch-test")

    live |> element("#toggle-wrap") |> render_click()
    assert live |> element("#resend") |> render_click() =~ "re-sends 1"
  end

  test "the tick can be moved out of the component subtrees", %{conn: conn} do
    {:ok, live, html} = live(conn, ~p"/patch-test")
    assert html =~ "Tick inside the modal"

    html = live |> element("#toggle-inside") |> render_click()
    refute html =~ "Tick inside the modal"
  end
end
