import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :quick_average, QuickAverageWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base:
    "4qt+wsOzyogsO0/Uy+8wkRHxTpzMMy4OguVQereWELuYN30O7zYpXbRgsfCHdpXB",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
