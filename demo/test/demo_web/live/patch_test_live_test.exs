defmodule DemoWeb.PatchTestLiveTest do
  use DemoWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "renders the component that is selected, and only that one", %{
    conn: conn
  } do
    {:ok, _live, html} = live(conn, ~p"/patch-test")

    assert html =~ "LiveView patch test"
    assert html =~ "test-modal"

    for id <- ~w(test-alert-dialog test-carousel test-tabs test-accordion
                 test-split-pane test-disclosure) do
      refute html =~ id
    end
  end

  test "the picker selects the component under test", %{conn: conn} do
    {:ok, live, _html} = live(conn, ~p"/patch-test")

    html =
      live
      |> form("#component-picker", %{"component" => "toggle_button"})
      |> render_change()

    assert html =~ "test-toggle-button" or
             has_element?(live, "button[aria-pressed]")

    refute html =~ "test-modal"
  end

  test "the slide controls belong to the carousel", %{conn: conn} do
    {:ok, live, _html} = live(conn, ~p"/patch-test")

    refute has_element?(live, "#add-slide")

    live
    |> form("#component-picker", %{"component" => "carousel"})
    |> render_change()

    assert has_element?(live, "#add-slide")
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
