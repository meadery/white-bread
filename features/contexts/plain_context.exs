defmodule WhiteBread.Example.PlainContext do
  @behaviour WhiteBread.ContextBehaviour
  alias WhiteBread.Step

  def get_steps do
    [
      Step.def_given("I want more", fn _state ->
         {:ok, :want_more}
      end),

      Step.def_given("I had a heart", fn :want_more ->
         {:ok, "have a heart"}
      end),

      Step.def_given("I had a voice", fn ->
        # Arity zero funcs don't have to return anything
        nil
      end),

      Step.def_then("I could love you", fn "have a heart" ->
        {:ok, :love}
      end),

      Step.def_then(~r/^I would (?<action>[a-z]+)$/, fn _state, %{action: "sing"} ->
         {:ok, :singing}
      end)
    ]

  end

  def feature_starting_state() do
      # Always default to an empty map
      %{}
  end

  def scenario_starting_state(feature_state) do
      feature_state
  end

  def scenario_finalize(_ignored_status, _ignored_state), do: nil
  def feature_finalize(_ignored_status, _ignored_state), do: nil

  def get_scenario_timeout(_feature, _scenario) do
    10_000
  end

end
