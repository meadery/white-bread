defmodule WhiteBread.Suite do
  defstruct name: "",
            context: nil,
            tags: nil,
            roles: nil,
            feature_paths: [],
            run_async: false

  def set_properties(%__MODULE__{} = suite, properties)
  when is_list(properties)
  do
    properties |> Enum.reduce(suite, &set_property/2)
  end

  defp set_property({key, value}, suite) do
    suite |> Map.update!(key, fn _ -> value end)
  end
end
