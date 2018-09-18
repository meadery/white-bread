defmodule WhiteBread.TestContextPerFeature.MyFeatureAContext do
  use WhiteBread.Context

  def_given ~r/^(?<anything>.+)$/, fn state, %{anything: _anything} ->
    {:ok, state}
  end
end
