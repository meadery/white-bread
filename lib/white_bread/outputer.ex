defmodule WhiteBread.Outputer do
  alias WhiteBread.EventManager

  def report({:final_results, result_map}) do
    EventManager.report({:final_results, result_map})
  end

  def report({:suite, suite_name}) do
    EventManager.report({:suite, suite_name})
  end

  def report({:scenario_result, result_tuple, scenario_or_outline}) do
    EventManager.report({:scenario_result, result_tuple, scenario_or_outline})
  end

end
