defmodule DemoWeb.CanonicalHostTest do
  use ExUnit.Case, async: true

  import Plug.Conn
  import Plug.Test

  alias DemoWeb.CanonicalHost

  @canonical_host "doggo.wlyx.dev"

  defmodule Endpoint do
    @canonical_host "doggo.wlyx.dev"

    def host, do: @canonical_host
    def url, do: "https://#{@canonical_host}"
  end

  defp call(conn) do
    CanonicalHost.call(conn, CanonicalHost.init(endpoint: Endpoint))
  end

  test "returns conn unchanged with canonical host" do
    conn = %{conn(:get, "/storybook") | host: @canonical_host}
    assert call(conn) == conn
  end

  test "redirects GET request with other host" do
    conn = call(%{conn(:get, "/storybook") | host: "woylie-doggo.fly.dev"})

    assert conn.halted
    assert conn.status == 301

    assert get_resp_header(conn, "location") == [
             "https://doggo.wlyx.dev/storybook"
           ]
  end

  test "redirects HEAD request if request uses other host" do
    conn = call(%{conn(:head, "/storybook") | host: "woylie-doggo.fly.dev"})

    assert conn.halted
    assert conn.status == 301

    assert get_resp_header(conn, "location") == [
             "https://doggo.wlyx.dev/storybook"
           ]
  end

  test "keeps the path and the query string" do
    conn =
      call(%{conn(:get, "/storybook/buttons?tab=source") | host: "fly.dev"})

    assert get_resp_header(conn, "location") == [
             "https://#{@canonical_host}/storybook/buttons?tab=source"
           ]
  end

  test "redirects the root path" do
    conn = call(%{conn(:get, "/") | host: "fly.dev"})
    assert get_resp_header(conn, "location") == ["https://#{@canonical_host}/"]
  end

  test "redirects methods other than GET and HEAD to the home page" do
    conn = call(%{conn(:post, "/storybook?tab=source") | host: "fly.dev"})

    assert conn.halted
    assert conn.status == 303
    assert get_resp_header(conn, "location") == ["https://#{@canonical_host}/"]
  end

  test "returns conn unchanged with canonical host and other methods" do
    conn = %{conn(:post, "/storybook") | host: @canonical_host}
    assert call(conn) == conn
  end
end
