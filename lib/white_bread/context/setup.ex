defmodule WhiteBread.Context.Setup do
  def before do
    quote do
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
end
