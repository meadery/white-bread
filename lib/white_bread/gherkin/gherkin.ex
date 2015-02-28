defmodule WhiteBread.Gherkin do

  defmodule Elements do
    defmodule Feature, do: defstruct name: "", description: "", scenarios: []
    defmodule Scenario, do: defstruct name: "", steps: []
  end

end
