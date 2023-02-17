defmodule QuickAverage.DisplayState do
  alias QuickAverage.DisplayNumber
  alias QuickAverage.User

  @enforce_keys [:users, :average]
  defstruct [:users, :average]

  def from_input_state(%{presences: presences, reveal: reveal}) do
    presences
    |> Map.values()
    |> Enum.map(&metas_to_user/1)
    |> Enum.sort()
    |> determine_active_users()
    |> determine_should_reveal(reveal)
    |> update_user_display_numbers()
    |> determine_average()
  end

  defp metas_to_user([%{user: %User{} = user} | _]), do: user

  defp metas_to_user(%{metas: meta}) do
    metas_to_user(meta)
  end

  defp determine_active_users(users) do
    active_users = Enum.filter(users, &(!&1.only_viewing))

    %{users: users, active_users: active_users}
  end

  defp determine_should_reveal(state, true) do
    Map.put(state, :reveal, true)
  end

  defp determine_should_reveal(
         %{users: users, active_users: active_users},
         false
       ) do
    should_reveal = should_reveal?(active_users)
    %{users: users, reveal: should_reveal, active_users: active_users}
  end

  defp update_user_display_numbers(%{
         users: users,
         reveal: should_reveal,
         active_users: active_users
       }) do
    users =
      users
      |> Enum.map(
        &Map.replace!(
          &1,
          :number,
          display_number(Map.put(&1, :reveal, should_reveal))
        )
      )

    %{users: users, reveal: should_reveal, active_users: active_users}
  end

  defp should_reveal?(users) do
    users
    |> Enum.all?(&is_number(&1.number))
  end

  defp display_number(%{only_viewing: true}), do: "Viewing"

  defp display_number(%{reveal: true, number: number}) when is_number(number) do
    DisplayNumber.parse(number)
  end

  defp display_number(%{reveal: false, number: number}) when is_number(number),
    do: "Hidden"

  defp display_number(_), do: "Waiting"

  defp determine_average(%{users: users, reveal: false}) do
    %__MODULE__{
      users: users,
      average: "Waiting"
    }
  end

  defp determine_average(%{
         users: users,
         active_users: active_users,
         reveal: true
       }) do
    %__MODULE__{
      users: users,
      average: average(active_users)
    }
  end

  defp average([]), do: "Waiting"

  defp average(users) do
    numbers = Enum.map(users, & &1.number) |> Enum.filter(&is_number/1)

    if Enum.empty?(numbers) do
      "Waiting"
    else
      DisplayNumber.parse(Enum.sum(numbers) / Enum.count(numbers))
    end
  end
end
