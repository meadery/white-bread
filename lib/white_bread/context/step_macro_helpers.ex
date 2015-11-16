defmodule WhiteBread.Context.StepMacroHelpers do
  # Regexes
  def define_block_step({:sigil_r, _, _} = step_regex, block) do
    function_name = step_name(step_regex)
    quote do
      @regex_steps [{unquote(step_regex), &__MODULE__.unquote(function_name)/2}
                    | @regex_steps]
      def unquote(function_name)(state, _extra \\ []) do
        unquote(block)
        {:ok, state}
      end
    end
  end

  def define_block_step(step_text, block) do
    function_name = step_name(step_text)
    quote do
      @string_steps @string_steps
        |> Dict.put(unquote(step_text), &__MODULE__.unquote(function_name)/2)
      def unquote(function_name)(state, _extra \\ []) do
        unquote(block)
        {:ok, state}
      end
    end
  end

  # regexes
  def define_function_step({:sigil_r, _, _} = step_regex, function) do
    function_name = step_name(step_regex)
    quote do
      @regex_steps [{unquote(step_regex), &__MODULE__.unquote(function_name)/2}
                    | @regex_steps]
      def unquote(function_name)(state, extra \\ []) do
        case is_function(unquote(function), 1) do
          true  -> unquote(function).(state)
          false -> apply(unquote(function), [state, extra])
        end
      end
    end
  end

  def define_function_step(step_text, function) do
    function_name = step_name(step_text)
    quote do
      @string_steps @string_steps
       |> Dict.put(unquote(step_text), &__MODULE__.unquote(function_name)/2)
      def unquote(function_name)(state, extra \\ []) do
        case is_function(unquote(function), 1) do
          true  -> unquote(function).(state)
          false -> apply(unquote(function), [state, extra])
        end
      end
    end
  end

  defp step_name({:sigil_r, _, [{_, _, [string]}, _]}) do
    String.to_atom("regex_step_" <> string)
  end
  defp step_name(step_text) do
    String.to_atom("step_" <> step_text)
  end

end
