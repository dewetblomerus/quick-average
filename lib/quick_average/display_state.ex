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

  defp meta_to_user([%{"name" => name, "number" => number} | _tail]) do
    %{name: name, number: number}
  end

  defp meta_to_user(%{metas: meta}) do
    meta_to_user(meta)
  end

  defp from_users(raw_users) do
    users =
      Enum.map(raw_users, fn user_params ->
        User.from_params(user_params)
      end)

    %__MODULE__{
      users: users,
      average: average(users)
    }
  end

  def average([]), do: "Waiting"

  def average(users) do
    numbers = Enum.map(users, & &1.number)

    if Enum.all?(numbers, &is_number/1) do
      DisplayNumber.parse(Enum.sum(numbers) / Enum.count(numbers))
    else
      "Waiting"
    end
  end
end
