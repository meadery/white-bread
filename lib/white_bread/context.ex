defmodule WhiteBread.Context do

  alias WhiteBread.Context.StepMacroHelpers
  alias WhiteBread.Context.StepExecutor

  @step_keywords [:given_, :when_, :then_, :and_, :but_]

  @doc false
  defmacro __using__(_opts) do
    quote do
      import WhiteBread.Context
      import ExUnit.Assertions

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

    quote do
      def execute_step(step, state) do
        get_steps
          |> StepExecutor.execute_step(step, state)
      end

      def get_steps do
        @sub_context_modules
         |> Enum.map(fn(sub_module) -> apply(sub_module, :get_steps, []) end)
         |> Enum.flat_map(fn(x) -> x end)
         |> Enum.into(@steps)
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

      unless @scenario_finalize_defined do
        def finalize(_ignored_state), do: nil
      end

    end
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
