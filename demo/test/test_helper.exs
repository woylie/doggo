ExUnit.start(exclude: [:e2e])

# The end-to-end tests drive a browser against the running endpoint, as the
# Playwright suite's `webServer` does.
if :e2e in ExUnit.configuration()[:include] do
  config = Application.fetch_env!(:demo, DemoWeb.Endpoint)

  Application.put_env(
    :demo,
    DemoWeb.Endpoint,
    Keyword.put(config, :server, true)
  )

  :ok = Supervisor.terminate_child(Demo.Supervisor, DemoWeb.Endpoint)
  {:ok, _} = Supervisor.restart_child(Demo.Supervisor, DemoWeb.Endpoint)
end
