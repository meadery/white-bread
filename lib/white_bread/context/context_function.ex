defmodule WhiteBread.Context.ContextFunction do
  defstruct string: nil,
            regex: nil,
            function: nil,
            type: nil

  def new(%Regex{} = regex, func) do
    %__MODULE__{
      regex: regex,
      function: func,
      type: :regex
    }
  end

  def new(string, func) do
    %__MODULE__{
      string: string,
      function: func,
      type: :string
    }
  end

  def match?(%__MODULE__{type: :string} = data, string) do
    string == data.string
  end

  def match?(%__MODULE__{type: :regex} = data, string) do
    Regex.match?(data.regex, string)
  end

end
