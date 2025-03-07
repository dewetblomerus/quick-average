defmodule QuickAverage.MixProject do
  use Mix.Project

  def project do
    [
      app: :quick_average,
      version: "0.1.0",
      elixir: "~> 1.18",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {QuickAverage.Application, []},
      extra_applications: [:logger, :runtime_tools, :os_mon]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:esbuild, "~> 0.6", runtime: Mix.env() == :dev},
      {:floki, ">= 0.34.0", only: :test},
      {:gettext, "~> 0.22"},
      {:heroicons, "> 0.5.2"},
      {:jason, "~> 1.2"},
      {:mimic, "~> 1.7", only: :test},
      {:mix_test_watch, "~> 1.1", only: :dev, runtime: false},
      {:phoenix_ecto, "~> 4.4.2"},
      {:phoenix_html, "~> 3.3"},
      {:phoenix_live_dashboard, "> 0.8.0"},
      {:phoenix_live_reload, "~> 1.4", only: :dev},
      {:phoenix_live_view, "~> 0.20.0"},
      {:phoenix, "~> 1.7.7", override: true},
      {:plug_cowboy, "~> 2.6"},
      {:sobelow, "~> 0.12", only: [:dev, :test], runtime: false},
      {:tailwind, "~> 0.1.10", runtime: Mix.env() == :dev},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "assets.setup"],
      "assets.setup": [
        "tailwind.install --if-missing",
        "esbuild.install --if-missing"
      ],
      "assets.deploy": [
        "tailwind default --minify",
        "esbuild default --minify",
        "phx.digest"
      ]
    ]
  end
end
