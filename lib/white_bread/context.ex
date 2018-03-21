defmodule WhiteBread.Context do

  alias WhiteBread.Context.StepMacroHelpers
  alias WhiteBread.Context.Setup

  @step_keywords [:given_, :when_, :then_, :and_, :but_]
  @default_test_library :ex_unit

  @doc false
  defmacro __using__(opts \\ []) do
    opts = Keyword.merge [test_library: @default_test_library], opts
    [test_library: test_library] = opts

    quote do
      import WhiteBread.Context
      unquote(import_test_library test_library)

      @behaviour WhiteBread.ContextBehaviour

      @steps []

      @sub_context_modules []

      @scenario_state_definied false
      @scenario_finalize_defined false
      @feature_state_definied false
      @feature_finalize_defined false

      @timeouts_definied false

      @before_compile WhiteBread.Context
    end
  end

  @doc false
  defmacro __before_compile__(_env) do
    Setup.before
  end

  for word <- @step_keywords do

    defmacro unquote(word)(step_text, do: block) do
      StepMacroHelpers.add_block_to_steps(step_text, block)
    end

    defmacro unquote(word)(step_text, func_def) do
      StepMacroHelpers.add_func_to_steps(step_text, func_def)
    end

  end

  defmacro feature_starting_state(function) do
    quote do
      @feature_state_definied true
      def feature_starting_state() do
        unquote(function).()
      end
    end
  end

  defmacro scenario_starting_state(function) do
    quote do
      @scenario_state_definied true
      def scenario_starting_state(state) do
        unquote(function).(state)
      end
    end
  end

  defmacro scenario_finalize(function) do
    quote do
      @scenario_finalize_defined true
      def scenario_finalize(status \\ nil, state) do
        cond do
          is_function(unquote(function), 2)
            -> unquote(function).(status, state)
          is_function(unquote(function), 1)
            -> unquote(function).(state)
          is_function(unquote(function), 0)
            -> unquote(function).()
        end
      end
    end
  end

  defmacro feature_finalize(function) do
    quote do
      @feature_finalize_defined true
      def feature_finalize(status \\ nil, state) do
        cond do
          is_function(unquote(function), 2)
            -> unquote(function).(status, state)
          is_function(unquote(function), 1)
            -> unquote(function).(state)
          is_function(unquote(function), 0)
            -> unquote(function).()
        end
      end
    end
  end

  defmacro scenario_timeouts(function) do
    quote do
      @timeouts_definied true
      def get_scenario_timeout(feature, scenario) do
        unquote(function).(feature, scenario)
      end
    end
  end

  defmacro import_steps_from(context_module) do
    quote do
      @sub_context_modules [unquote(context_module) | @sub_context_modules]
    end
  end

  defp import_test_library(test_library) do
    case test_library do
      :ex_unit -> quote do: import ExUnit.Assertions
      :espec -> quote do
        require ESpec
        use ESpec
      end
      nil -> quote do: true
      _ -> raise ArgumentError, "#{inspect test_library} is not a recognized value for :test_library. Recognized values are :ex_unit, :espec, and nil."
    end
  end
end
