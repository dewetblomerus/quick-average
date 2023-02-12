defmodule QuickAverage.DisplayNumber do
  def parse(number) when is_integer(number), do: number

  def parse(number) when is_float(number) do
    number
    |> Float.round(2)
    |> integerize()
  end

  defp integerize(number) when is_float(number) do
    if number && number == round(number) do
      round(number)
    else
      number
    end
  end
end
