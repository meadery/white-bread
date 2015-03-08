defmodule WhiteBread.Gherkin do

  defmodule Elements do
    defmodule Feature, do: defstruct name: "", description: "", background_steps: [], scenarios: []
    defmodule Scenario, do: defstruct name: "", steps: []

    defmodule Steps do
      defmodule Given, do: defstruct text: ""
      defmodule When, do: defstruct text: ""
      defmodule Then, do: defstruct text: ""
      defmodule And, do: defstruct text: ""
      defmodule But, do: defstruct text: ""
    end

  end

end
