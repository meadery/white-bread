defmodule WhiteBread.TestContextPerFeature.MyFeatureAContext do
  use WhiteBread.Context

  given_ ~r/^(?<anything>.+)$/, fn state, %{anything: _anything} ->
    {:ok, state}
  end
end
