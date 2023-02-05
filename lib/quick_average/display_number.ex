defmodule QuickAverage.DisplayNumber do
  def parse(nil) do
    "Waiting"
  end

  def parse("") do
    "Waiting"
  end

  def parse(number) when is_binary(number) do
    cond do
      {float, ""} = Float.parse(number) -> Float.round(float, 2)
      true -> "Waiting"
    end
    |> integerize()
  end

  def parse(number) when is_integer(number) or is_float(number) do
    number
  end

  defp integerize(number) when is_float(number) do
    if number && number == Float.round(number) do
      number
      |> round()
    else
      number
    end
  end
end
