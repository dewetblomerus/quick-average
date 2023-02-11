defmodule QuickAverage.DisplayState do
  alias QuickAverage.DisplayNumber
  alias QuickAverage.User

  defstruct [:users, :average]
  @enforce_keys [:users, :average]

  def from_presences(presences) do
    presences
    |> Map.values()
    |> Enum.map(&meta_to_user/1)
    |> Enum.sort()
    |> from_users()
  end

  defp meta_to_user([%{user: %User{} = user} | _]), do: user

  defp meta_to_user(%{metas: meta}) do
    meta_to_user(meta)
  end

  defp from_users(users) do
    %__MODULE__{
      users: users,
      average: average(users)
    }
  end

  defp average([]), do: "Waiting"

  defp average(users) do
    numbers = Enum.map(users, & &1.number)

    if Enum.all?(numbers, &is_number/1) do
      DisplayNumber.parse(Enum.sum(numbers) / Enum.count(numbers))
    else
      "Waiting"
    end
  end
end
