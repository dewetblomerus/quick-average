defmodule QuickAverage.Users do
  def from_presences(presences) do
    presences
    |> Map.values()
    |> Enum.map(&meta_to_user/1)
    |> Enum.sort()
  end

  defp meta_to_user([%{"name" => name, "number" => number}]) do
    %{name: name, number: number}
  end

  defp meta_to_user(%{metas: meta}) do
    meta_to_user(meta)
  end
end
