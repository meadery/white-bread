defmodule WhiteBread.Context do

  @steps_to_macro [:given_, :when_, :then_, :and_, :but_]

  @doc false
  defmacro __using__(_opts) do
    quote do
      import WhiteBread.Context
      import ExUnit.Assertions

      @string_steps HashDict.new

      # List of tuples {regex, function}
      @regex_steps []

      @initital_state_definied false

      @before_compile WhiteBread.Context
    end
  end

  @doc false
  defmacro __before_compile__(_env) do
    quote do
      def execute_step(step, state) do
        {@string_steps, @regex_steps}
        |> WhiteBread.Context.StepExecutor.execute_step(step, state)
      end

      if !@initital_state_definied do
        # Default starting state should always be an empty map.
        def starting_state do
          %{}
        end
      end

    end
  end

  for step <- @steps_to_macro do

    defmacro unquote(step)(step_text, do: block) do
      define_block_step(step_text, block)
    end

    defmacro unquote(step)(step_text, step_function) do
      define_function_step(step_text, step_function)
    end
  end

  defmacro initial_state(do: block) do
    quote do
      @initital_state_definied true
      def starting_state() do
        unquote(block)
      end
    end
  end

  # Regexes
  defp define_block_step({:sigil_r, _, _} = step_regex, block) do
    function_name = regex_to_step_atom(step_regex)
    quote do
      @regex_steps [{unquote(step_regex), &__MODULE__.unquote(function_name)/2} | @regex_steps]
      def unquote(function_name)(state, _extra \\ []) do
        unquote(block)
        {:ok, state}
      end
    end
  end

  defp define_block_step(step_text, block) do
    function_name = String.to_atom("step_" <> step_text)
    quote do
      @string_steps Dict.put(@string_steps, unquote(step_text), &__MODULE__.unquote(function_name)/2)
      def unquote(function_name)(state, _extra \\ []) do
        unquote(block)
        {:ok, state}
      end
    end
  end

  # regexes
  defp define_function_step({:sigil_r, _, _} = step_regex, function) do
    function_name = regex_to_step_atom(step_regex)
    quote do
      @regex_steps [{unquote(step_regex), &__MODULE__.unquote(function_name)/2} | @regex_steps]
      def unquote(function_name)(state, extra \\ []) do
        case is_function(unquote(function), 1) do
          true  -> unquote(function).(state)
          false -> apply(unquote(function), [state, extra])
        end
      end
    end
  end

  defp define_function_step(step_text, function) do
    function_name = String.to_atom("step_" <> step_text)
    quote do
      @string_steps Dict.put(@string_steps, unquote(step_text), &__MODULE__.unquote(function_name)/2)
      def unquote(function_name)(state, extra \\ []) do
        case is_function(unquote(function), 1) do
          true  -> unquote(function).(state)
          false -> apply(unquote(function), [state, extra])
        end
      end
    end
  end

  defp regex_to_step_atom({:sigil_r, _, [{_, _, [string]}, _]}) do
    String.to_atom("regex_step_" <> string)
  end

end
