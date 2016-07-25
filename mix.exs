defmodule Restarter.Mixfile do
  use Mix.Project

  def project do
    [app: :restarter,
     version: "0.1.0",
     elixir: "~> 1.3",
     description: description(),
     package: package(),
     deps: deps(),]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:credo, "~> 0.4", only: [:dev, :test]},
      {:ex_doc, "~> 0.12", only: :dev},
    ]
  end

  defp description do
  """
  The `Restarter` allows you to set a retry interval for restarting a child process. The child will be restarted for indefinitely.

  Useful for processes that rely on external connections
  """
  end

  defp package do
    [
      name: :restarter,
      files: ["lib", "mix.exs", "README.md", "LICENSE.md"],
      maintainers: ["Paul Wilson"],
      licenses: ["MIT"],
      links: %{}
    ]
  end
end
