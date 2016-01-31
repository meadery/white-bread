defmodule WhiteBread.Context do

  alias WhiteBread.Context.StepMacroHelpers
  alias WhiteBread.Context.Setup

  @step_keywords [:given_, :when_, :then_, :and_, :but_]

  @doc false
  defmacro __using__(_opts) do
    quote do
      import WhiteBread.Context
      import ExUnit.Assertions

      @behaviour WhiteBread.ContextBehaviour

      @steps []

      @sub_context_modules []

      @scenario_state_definied false
      @scenario_finalize_defined false
      @feature_state_definied false

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

  defmacro scenario_finalize(function) do
    quote do
      @scenario_finalize_defined true
      def finalize(state) do
        cond do
          is_function(unquote(function), 1)
            -> unquote(function).(state)
          is_function(unquote(function), 0)
            -> unquote(function).()
        end
      end
    end
  end

  defmacro subcontext(context_module) do
    quote do
      @sub_context_modules [unquote(context_module) | @sub_context_modules]
    end
  end


end
