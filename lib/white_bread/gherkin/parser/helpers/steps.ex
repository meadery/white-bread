defmodule WhiteBread.Gherkin.Parser.Helpers.Steps do
  alias WhiteBread.Gherkin.Elements.Steps, as: Steps

  def process_background_step_line(line, feature) do
    %{background_steps: current_background_steps} = feature
    new_step = string_to_step(line)
    {
      %{feature | background_steps: current_background_steps ++ [new_step]},
      :background_steps
    }
  end

  def process_scenario_step_line(line, feature) do
    %{scenarios: [scenario | rest]} = feature
    updated_scenario = add_step_to_scenario(scenario, line)
    {
      %{feature | scenarios: [updated_scenario | rest]},
      :scenario_steps
    }
  end

  @doc ~S"""
  Takes a string representing a step and adds it to the scenario as a struct

  ## Examples

  iex> add_step_to_scenario(%{steps: []}, "When I add this line")
  %{steps: [%Steps.When{text: "I add this line"}]}

  """
  def add_step_to_scenario(scenario, line) do
    step  = string_to_step(line)
    %{steps: current_steps} = scenario
    %{scenario | steps: current_steps ++ [step]}
  end

  @doc ~S"""
  Returns the appropriate struct for a step string

  ## Examples

  iex> string_to_step("Given this works")
  %Steps.Given{text: "this works"}

  iex> string_to_step("Then it might be useful")
  %Steps.Then{text: "it might be useful"}

  """
  def string_to_step(string) do
    case string do
      "Given " <> text -> %Steps.Given{text: text}
      "When " <> text  -> %Steps.When{text: text}
      "Then " <> text  -> %Steps.Then{text: text}
      "And " <> text  -> %Steps.And{text: text}
      "But " <> text  -> %Steps.But{text: text}
    end
  end

end
