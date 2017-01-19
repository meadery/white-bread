use Mix.Config
config :logger, :console, level: :warn

config :white_bread,
  outputer: WhiteBread.Outputers.HTML,
  path: "~/fu/bar/baz.html"
