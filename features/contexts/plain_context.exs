defmodule WhiteBread.Example.PlainContext do
  alias WhiteBread.Context.StepFunction

  def get_steps do
    [
      StepFunction.new("I want more", fn _state ->
         {:ok, :want_more}
      end),

      StepFunction.new("I had a heart", fn :want_more ->
         {:ok, "have a heart"}
      end),

      StepFunction.new("I had a voice", fn ->
        # Arity zero funcs don't have to return anything
      end),

      StepFunction.new("I could love you", fn "have a heart" ->
        {:ok, :love}
      end),

      StepFunction.new(~r/^I would (?<action>[a-z]+)$/, fn _state, %{action: "sing"} ->
         {:ok, :singing}
      end)
    ]

  end

  def feature_state() do
      # Always default to an empty map
      %{}
  end

  def starting_state(feature_state) do
      feature_state
  end

  def finalize(_ignored_state), do: nil

end
