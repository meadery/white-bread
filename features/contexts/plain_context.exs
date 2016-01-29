defmodule WhiteBread.Example.PlainContext do
  alias WhiteBread.Context.ContextFunction

  def get_steps do
    [
      ContextFunction.new("I want more", fn _state , _extra ->
         {:ok, :want_more}
      end),

      ContextFunction.new("I had a heart", fn :want_more, _extra ->
         {:ok, "have a heart"}
      end),

      ContextFunction.new("I had a voice", fn :want_more, _extra ->
        {:ok, "have a voice"}
      end),

      ContextFunction.new("I could love you", fn "have a heart", _extra ->
        {:ok, :love}
      end),

      ContextFunction.new("I would sing", fn "have a voice", _extra ->
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
