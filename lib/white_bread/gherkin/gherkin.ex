defmodule WhiteBread.Gherkin do

  defmodule Elements do

    defmodule Feature do
      defstruct name: "",
                description: "",
                tags: [],
                background_steps: [],
                scenarios: []
    end

    defmodule Scenario do
       defstruct name: "",
                 tags: [],
                 steps: []
    end

    defmodule ScenarioOutline do
      defstruct name: "",
                tags: [],
                steps: [],
                examples: []
    end

    defmodule Steps do
      defmodule Given, do: defstruct text: "", table_data: []
      defmodule When,  do: defstruct text: "", table_data: []
      defmodule Then,  do: defstruct text: "", table_data: []
      defmodule And,   do: defstruct text: "", table_data: []
      defmodule But,   do: defstruct text: "", table_data: []
    end

  end

end
