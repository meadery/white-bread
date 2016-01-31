defmodule WhiteBread.Example.PlainContext do
  alias WhiteBread.Context.ContextFunction

  def get_steps do
    [
      ContextFunction.new("I want more", fn _state ->
         {:ok, :want_more}
      end),

      ContextFunction.new("I had a heart", fn :want_more ->
         {:ok, "have a heart"}
      end),

      ContextFunction.new("I had a voice", fn ->
        # Arity zero funcs don't have to return anything
      end),

      ContextFunction.new("I could love you", fn "have a heart" ->
        {:ok, :love}
      end),

      ContextFunction.new(~r/^I would (?<action>[a-z]+)$/, fn _state, %{action: "sing"} ->
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
