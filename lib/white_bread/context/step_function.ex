defmodule WhiteBread.Context.StepFunction do
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

  def match?(%__MODULE__{type: :string} = data, string) do
    string == data.string
  end

  def match?(%__MODULE__{type: :regex} = data, string) do
    Regex.match?(data.regex, string)
  end

end
