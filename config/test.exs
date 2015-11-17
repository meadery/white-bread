use Mix.Config
config :logger, :console, level: :warn

config :dogma,
  rule_set: Dogma.RuleSet.All,
  override: %{ ModuleDoc => false,
               ExceptionName => false}
