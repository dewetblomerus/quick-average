defmodule Support.Factory do
  alias QuickAverage.User

  def input_state_for(users) when is_list(users) do
    %{presences: presences_for(users), is_revealed_manually: false}
  end

  def presences_for(users) when is_list(users) do
    users
    |> metas_for()
    |> Map.new(fn meta ->
      {random_ref(), [meta]}
    end)
  end

  def presence_list_for(users) when is_list(users) do
    users
    |> metas_for()
    |> Map.new(fn meta ->
      {random_ref(), %{metas: [meta]}}
    end)
  end

  defp metas_for(users) when is_list(users) do
    Enum.map(users, fn %User{} = user ->
      %{
        phx_ref: random_ref(),
        phx_ref_prev: random_ref(),
        user: user
      }
    end)
  end

  defp random_ref do
    "phx-#{Enum.random(1000..9999)}"
  end
end
