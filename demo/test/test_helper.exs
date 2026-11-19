ExUnit.start(exclude: [:e2e])

# The end-to-end tests drive a browser against the running endpoint.
if :e2e in ExUnit.configuration()[:include] do
  # Playwright Test's default test timeout.
  ExUnit.configure(timeout: 30_000)

  # One test at a time on CI, as `workers: 1` (queued tests would spend their timeout waiting).
  if System.get_env("CI"), do: ExUnit.configure(max_cases: 1)

  config = Application.fetch_env!(:demo, DemoWeb.Endpoint)

  Application.put_env(
    :demo,
    DemoWeb.Endpoint,
    Keyword.put(config, :server, true)
  )

  :ok = Supervisor.terminate_child(Demo.Supervisor, DemoWeb.Endpoint)
  {:ok, _} = Supervisor.restart_child(Demo.Supervisor, DemoWeb.Endpoint)
end
