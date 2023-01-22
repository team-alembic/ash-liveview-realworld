import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :realworld_web, RealworldWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "os4uW7DeMJ1ipPfIDI0HvLUkWeXWNbAApXYLdV236CYu8OLmN88RkFvosbjyd0xP",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :realworld, Realworld.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "realworld_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# JWT Secret
config :ash_authentication,
  authentication: [
    tokens: [
      signing_secret:
        "arb_9Z_yUe1kM@*-fJK=B}2W!RZ?C.iiK>@-:Un9-@UoCWyV!0Yvy+ErBU7}+gPs}V8k0rg!2D:fAr"
    ]
  ]
