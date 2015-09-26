defmodule Dogma.WhiteBread.Rules do
  @moduledoc """
  The module which defines all the rules to run in Dogma.

  Rules to be run are returned by `list/0`
  """

  def rules do
    Dogma.RuleSet.All.rules
      |> Enum.reject(&skipped?/1)
  end

  defp skipped?({rule, _}),   do: skipped?({rule})
  defp skipped?({ModuleDoc}), do: true
  defp skipped?({_rule}),     do: false

end
