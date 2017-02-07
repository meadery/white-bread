defmodule WhiteBread.Roles.FeatureFilterer do
  alias Gherkin.Elements.Feature

  def get_for_roles(features, roles)
  when is_list(features) and is_list(roles)
  do
    features
      |> Enum.filter(&one_of_roles?(&1, roles))
  end

  defp one_of_roles?(%Feature{role: role}, roles) do
    Enum.member?(roles, role)
  end

end
