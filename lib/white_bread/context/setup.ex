defmodule WhiteBread.Context.Setup do
  def before do
    quote do
      # 30 seconds max per scenario
      @default_scenario_timeout 1000 * 30

      def get_steps do
        @sub_context_modules
         |> Enum.map(fn(sub_module) -> apply(sub_module, :get_steps, []) end)
         |> Enum.flat_map(fn(x) -> x end)
         |> Kernel.++(@steps)
      end

      unless @feature_state_definied do
        def feature_starting_state() do
          # Always default to an empty map
          %{}
        end
      end

      unless @scenario_state_definied do
        def scenario_starting_state(state) do
          state
        end
      end

      unless @scenario_finalize_defined do
        def scenario_finalize(_ignored_status, _ignored_state), do: nil
      end

      unless @feature_finalize_defined do
        def feature_finalize(_ignored_status, _ignored_state), do: nil
      end

      unless @timeouts_definied do
        def get_scenario_timeout(_feature, _scenario) do
          @default_scenario_timeout
        end
      end

    end
  end
end
