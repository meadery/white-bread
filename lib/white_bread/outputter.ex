defmodule WhiteBread.Outputter do
  alias WhiteBread.EventManager

  def report({:final_results, result_map}) do
    EventManager.report({:final_results, result_map})
  end

  def report({:suite, suite.name}) do
    EventManager.report({:suite, suite.name})
  end

  def report({:scenario_result, result_tuple, scenario_or_outline}) do
    EventManager.report({:scenario_result, result_tuple, scenario_or_outline})
  end

end
