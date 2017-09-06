defmodule WhiteBread.Context.StepFunction do

  alias WhiteBread.RegexExtension

  defstruct string: nil,
            regex: nil,
            function: nil,
            type: nil

  def new(%Regex{} = regex, func) when is_function(func, 2) do
    %__MODULE__{
      regex: regex,
      function: func,
      type: :regex
    }
  end

  def new(string, func) when is_function(func, 2) do
    %__MODULE__{
      string: string,
      function: func,
      type: :string
    }
  end

  # All stored funcs must be arity two
  def new(match, func) when is_function(func, 1) do
    wrapped_func = fn(state, _extra) ->
      func.(state)
    end
    new(match, wrapped_func)
  end

  # All stored funcs must be arity two
  def new(match, func) when is_function(func, 0) do
    wrapped_func = fn(state, _extra) ->
      func.()
      {:ok, state}
    end
    new(match, wrapped_func)
  end

  def type(%__MODULE__{type: type}) do
    type
  end

  @doc ~S"""
  Indicates if the step function matches the given string.
  String step functions match if the whole string matches.
  Regex steps pass the call to Regex.match?

  ## Example - String step functions

      iex> step_function = StepFunction.new("hello midgard", fn -> :hooray end)
      iex> StepFunction.match?(step_function, "hello midgard")
      true

      iex> step_function = StepFunction.new("hello asgard", fn -> :hooray end)
      iex> StepFunction.match?(step_function, "hello midgard")
      false

  ## Example - Regex step functions

      iex> step_function = StepFunction.new(~r/^hello (.+)$/, fn -> :hooray end)
      iex> StepFunction.match?(step_function, "hello midgard")
      true

      iex> step_function = StepFunction.new(~r/^hello ([a-z]+)$/, fn -> :hooray end)
      iex> StepFunction.match?(step_function, "hello midgard 9")
      false
  """
  def match?(%__MODULE__{type: :string} = data, string) do
    string == data.string
  end

  def match?(%__MODULE__{type: :regex} = data, string) do
    Regex.match?(data.regex, string)
  end

  def call(%__MODULE__{type: :string, function: func}, step, state) do
    args = [state, {:table_data, step.table_data}]
    apply(func, args)
  end

  def call(%__MODULE__{type: :regex, function: func, regex: regex}, step, state) do
    key_matches = RegexExtension.atom_keyed_named_captures(
      regex,
      step.text
    )
    extra = Map.new
      |> Map.merge(key_matches)
      |> Map.put(:table_data, step.table_data)
      |> Map.put(:doc_string, step.doc_string)
    apply(func, [state, extra])
  end

end
