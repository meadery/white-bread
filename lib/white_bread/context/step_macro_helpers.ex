defmodule WhiteBread.Context.StepMacroHelpers do
  alias WhiteBread.Context.StepFunction

  def add_func_to_steps(step_text, func_def) do
    fn_name = step_name(step_text)
    quote do
      def unquote(fn_name)(state, extra \\ []) do
        func = unquote(func_def)
        cond do
          is_function(func, 1) -> func.(state)
          is_function(func, 2) -> func.(state, extra)
        end
      end
      new = StepFunction.new(
        unquote(step_text),
        &__MODULE__.unquote(fn_name)/2
      )
      @steps @steps ++ [new]
    end
  end

  def add_block_to_steps(step_text, block) do
    fn_name = step_name(step_text)
    quote do
      def unquote(fn_name)(state, extra \\ []) do
        unquote(block)
        {:ok, state}
      end
      new = StepFunction.new(
        unquote(step_text),
        &__MODULE__.unquote(fn_name)/2
      )
      @steps @steps ++ [new]
    end
  end

  defp step_name({:sigil_r, _, [{_, _, [string]}, _]}) do
    String.to_atom("regex_step_" <> string)
  end
  defp step_name(step_text) do
    String.to_atom("step_" <> step_text)
  end

end
