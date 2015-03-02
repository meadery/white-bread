defmodule WhiteBread.Context do

  @steps_to_macro [:given_, :when_, :then_, :and_, :but_]

  @doc false
  defmacro __using__(_opts) do
    quote do
      import WhiteBread.Context

      @string_steps %{}

      @before_compile WhiteBread.Context
    end
  end

  @doc false
  defmacro __before_compile__(_env) do
    quote do
      def execute_step(%{text: step_text} = step, state) do
        function = Dict.fetch!(@string_steps, step_text)
        function.(state)
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

  defp define_block_step(step_text, block) do
    function_name = String.to_atom("step_" <> step_text)
    quote do
      @string_steps Dict.put(@string_steps, unquote(step_text), &__MODULE__.unquote(function_name)/1)
      def unquote(function_name)(state) do
        unquote(block)
        {:ok, state}
      end
    end
  end

  defp define_function_step(step_text, function) do
    function_name = String.to_atom("step_" <> step_text)
    quote do
      @string_steps Dict.put(@string_steps, unquote(step_text), &__MODULE__.unquote(function_name)/1)
      def unquote(function_name)(state) do
        unquote(function).(state)
      end
    end
  end

end
