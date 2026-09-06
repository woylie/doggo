defmodule Doggo.PackageVersionTest do
  use ExUnit.Case, async: true

  @package_json "assets/package.json"

  test "the npm package has the same version as the Hex package" do
    hex = Mix.Project.config()[:version]
    npm = npm_version()

    assert hex == npm, """
    The Hex and npm packages disagree about the version.

      mix.exs: #{hex}
      #{@package_json}: #{npm}
    """
  end

  defp npm_version do
    [_, version] =
      Regex.run(~r/^\s*"version":\s*"([^"]+)"/m, File.read!(@package_json))

    version
  end
end
