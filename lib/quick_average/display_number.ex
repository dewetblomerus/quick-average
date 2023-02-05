defmodule QuickAverage.DisplayNumber do
  def parse(nil) do
    "Waiting"
  end

  def parse("") do
    "Waiting"
  end

  def parse(number) when is_binary(number) do
    cond do
      {float, ""} = Float.parse(number) -> parse(float)
      true -> "Waiting"
    end
  end

  def parse(number) when is_integer(number), do: number

  def parse(number) when is_float(number) do
    number
    |> Float.round(2)
    |> integerize()
  end

  defp integerize(number) when is_float(number) do
    if number && number == Float.round(number) do
      round(number)
    else
      number
    end
  end
end
