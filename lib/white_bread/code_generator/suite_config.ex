defmodule WhiteBread.CodeGenerator.SuiteConfig do

  @empty_config """
  defmodule WhiteBreadConfig do
    use WhiteBread.SuiteConfiguration

    suite name:          "All",
          context:       WhiteBreadContext,
          feature_paths: ["features/"]
  end
  """

  def empty_config do
    @empty_config
  end


end
