# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :toolshed,
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :toolshed, ToolshedWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: ToolshedWeb.ErrorHTML, json: ToolshedWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Toolshed.PubSub,
  live_view: [signing_salt: "4ZrSNhlx"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.25.4",
  toolshed: [
    args:
      ~w(js/app.js --bundle --target=es2022 --outdir=../priv/static/assets/js --external:/fonts/* --external:/images/* --alias:@=.),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => [Path.expand("../deps", __DIR__), Mix.Project.build_path()]}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "4.1.7",
  toolshed: [
    args: ~w(
      --input=assets/css/app.css
      --output=priv/static/assets/css/app.css
    ),
    cd: Path.expand("..", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :ffmpex, ffmpeg_path: "ffmpeg"
config :ffmpex, ffprobe_path: "ffprobe"

config :mogrify,
  mogrify_command: [
    path: "magick",
    args: ["mogrify"]
  ],
  convert_command: [
    path: "magick",
    args: ["convert"]
  ],
  identify_command: [
    path: "magick",
    args: ["identify"]
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
