defmodule WhiteBread.Context.FAIL do

  @steps_to_macro [:given_, :when_, :then_, :and_, :but_]

  @doc false
  defmacro __using__(_opts) do
    quote do
      import WhiteBread.Context
      import ExUnit.Assertions

      @string_steps HashDict.new

      # List of tuples {regex, function}
      @regex_steps []

      @sub_context_modules []

      @scenario_state_definied false
      @feature_state_definied false

      @before_compile WhiteBread.Context
    end
  end

  @doc false
  defmacro __before_compile__(_env) do

    quote do
      def execute_step(step, state) do
        {get_string_steps, get_regex_steps}
        |> WhiteBread.Context.StepExecutor.execute_step(step, state)
      end

      def get_string_steps do
        get_from_submodule_function(:get_string_steps)
        |> Enum.into(@string_steps)
      end

      def get_regex_steps do
        get_from_submodule_function(:get_regex_steps)
        |> Enum.into(@regex_steps)
      end

      unless @feature_state_definied do
        def feature_state() do
          # Always default to an empty map
          %{}
        end
      end

      unless @scenario_state_definied do
        def starting_state(state) do
          state
        end
      end

      defp get_from_submodule_function(function) do
        @sub_context_modules
        |> Enum.map(fn(sub_module) -> apply(sub_module, function, []) end)
        |> Enum.flat_map(fn(x) -> x end)
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

  defmacro feature_starting_state(function) do
    quote do
      @feature_state_definied true
      def feature_state() do
        unquote(function).()
      end
    end
  end

  defmacro scenario_starting_state(function) do
    quote do
      @scenario_state_definied true
      def starting_state(state) do
        unquote(function).(state)
      end
    end
  end

  defmacro subcontext(context_module) do
    quote do
      @sub_context_modules [unquote(context_module) | @sub_context_modules]
    end
  end

  # Regexes
  defp define_block_step({:sigil_r, _, _} = step_regex, block) do
    function_name = regex_to_step_atom(step_regex)
    quote do
      @regex_steps [{unquote(step_regex), &__MODULE__.unquote(function_name)/2}
                    | @regex_steps]
      def unquote(function_name)(state, _extra \\ []) do
        unquote(block)
        {:ok, state}
      end
    end
  end

  defp define_block_step(step_text, block) do
    function_name = String.to_atom("step_" <> step_text)
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
  defp define_function_step({:sigil_r, _, _} = step_regex, function) do
    function_name = regex_to_step_atom(step_regex)
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

  defp define_function_step(step_text, function) do
    function_name = String.to_atom("step_" <> step_text)
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

  defp regex_to_step_atom({:sigil_r, _, [{_, _, [string]}, _]}) do
    String.to_atom("regex_step_" <> string)
  end

end
