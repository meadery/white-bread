defmodule WhiteBread.Example.PlainContext do
  @behaviour WhiteBread.ContextBehaviour
  alias WhiteBread.Step

  def get_steps do
    [
      Step.given_("I want more", fn _state ->
         {:ok, :want_more}
      end),

      Step.given_("I had a heart", fn :want_more ->
         {:ok, "have a heart"}
      end),

      Step.given_("I had a voice", fn ->
        # Arity zero funcs don't have to return anything
      end),

      Step.then_("I could love you", fn "have a heart" ->
        {:ok, :love}
      end),

      Step.then_(~r/^I would (?<action>[a-z]+)$/, fn _state, %{action: "sing"} ->
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

end
