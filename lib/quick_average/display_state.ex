defmodule QuickAverage.DisplayState do
  alias QuickAverage.DisplayNumber
  alias QuickAverage.User

  @enforce_keys [:users, :average]
  defstruct [:users, :average]

  def from_presences(presences) do
    presences
    |> Map.values()
    |> Enum.map(&meta_to_user/1)
    |> Enum.sort()
    |> to_intermediate_state()
    |> from_users()
  end

  defp meta_to_user([%{user: %User{} = user} | _]), do: user

  defp meta_to_user(%{metas: meta}) do
    meta_to_user(meta)
  end

  defp to_intermediate_state(users) do
    should_reveal = Enum.all?(users, &is_number(&1.number))

    users
    |> Enum.map(&Map.put(&1, :number, display_number(should_reveal, &1.number)))
  end

  defp display_number(true, number) when is_number(number) do
    DisplayNumber.parse(number)
  end

  defp display_number(false, number) when is_number(number), do: "Hidden"
  defp display_number(false, _), do: "Waiting"

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
