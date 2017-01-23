use Mix.Config
config :logger, :console, level: :warn

config :white_bread,
  outputers: [{WhiteBread.Outputers.Console, []},
              {WhiteBread.Outputers.HTML, path: "~/fu/bar/baz.html"}
             ]
