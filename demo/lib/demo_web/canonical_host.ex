defmodule DemoWeb.CanonicalHost do
  @moduledoc """
  Redirects to the canonical host.
  """

  @behaviour Plug

  import Plug.Conn

  @impl Plug
  def init(opts) do
    Keyword.fetch!(opts, :endpoint)
  end

  @impl Plug
  def call(conn, endpoint) do
    if conn.host == endpoint.host() do
      conn
    else
      redirect(conn, endpoint)
    end
  end

  defp redirect(%Plug.Conn{method: method} = conn, endpoint)
       when method in ["GET", "HEAD"] do
    send_redirect(
      conn,
      :moved_permanently,
      url(endpoint, conn.request_path, conn.query_string)
    )
  end

  defp redirect(conn, endpoint) do
    send_redirect(conn, :see_other, url(endpoint, "/", ""))
  end

  defp send_redirect(conn, status, url) do
    conn
    |> put_resp_header("location", url)
    |> send_resp(status, "")
    |> halt()
  end

  defp url(endpoint, path, query) do
    uri = URI.parse(endpoint.url())
    query = if query == "", do: nil, else: query
    URI.to_string(%{uri | path: path, query: query})
  end
end
