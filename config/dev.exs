use Mix.Config

config :dogma,
  rule_set: Dogma.RuleSet.All,
  override: %{ ModuleDoc => false,
               ExceptionName => false,
               WindowsLineEndings => false}
