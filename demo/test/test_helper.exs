ExUnit.start(exclude: [:e2e])

# The end-to-end tests drive a browser against the running endpoint.
if :e2e in ExUnit.configuration()[:include] do
  # Playwright Test's default test timeout.
  ExUnit.configure(timeout: 30_000)

  config = Application.fetch_env!(:demo, DemoWeb.Endpoint)

  Application.put_env(
    :demo,
    DemoWeb.Endpoint,
    Keyword.put(config, :server, true)
  )

  :ok = Supervisor.terminate_child(Demo.Supervisor, DemoWeb.Endpoint)
  {:ok, _} = Supervisor.restart_child(Demo.Supervisor, DemoWeb.Endpoint)
end
