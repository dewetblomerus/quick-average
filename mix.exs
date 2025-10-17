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
      {:credo, "~> 1.7.13", only: [:dev, :test], runtime: false},
      {:esbuild, "~> 0.10.0", runtime: Mix.env() == :dev},
      {:ex_check, "~> 0.16.0", only: [:dev], runtime: false},
      {:floki, ">= 0.38.0", only: :test},
      {:gettext, "~> 1.0"},
      {:heroicons, "~> 0.5.6"},
      {:jason, "~> 1.4.4"},
      {:lazy_html, ">= 0.1.0", only: :test},
      {:mimic, "~> 2.1", only: :test},
      {:mix_audit, "~> 2.1", only: [:dev, :test], runtime: false},
      {:mix_test_watch, "~> 1.3.0", only: :dev, runtime: false},
      {:phoenix_ecto, "~> 4.6"},
      {:phoenix_html, "~> 4.3"},
      {:phoenix_live_dashboard, "~> 0.8.7"},
      {:phoenix_live_reload, "~> 1.6.1", only: :dev},
      {:phoenix_live_view, "~> 1.1"},
      {:phoenix, "~> 1.8", override: true},
      {:plug_cowboy, "~> 2.7.4"},
      {:sobelow, "~> 0.14.1", only: [:dev, :test], runtime: false},
      {:tailwind, "~> 0.4", runtime: Mix.env() == :dev},
      {:telemetry_metrics, "~> 1.1"},
      {:telemetry_poller, "~> 1.3.0"}
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
