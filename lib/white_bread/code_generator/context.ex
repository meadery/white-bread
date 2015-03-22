defmodule WhiteBread.CodeGenerator.Context do

  @empty_context """
  defmodule WhiteBread.DefaultContext do
    use WhiteBread.Context
  end
  """

  def empty_context do
    @empty_context
  end


end
