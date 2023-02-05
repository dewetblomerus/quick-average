defmodule QuickAverage.User do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:name, :string)
    field(:number, :float)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :number])
    |> validate_required([:name, :number])
  end

  def from_params(%{name: name, number: number}) do
    structify(name, number)
  end

  def from_params(%{"name" => name, "number" => number}) do
    structify(name, number)
  end

  def structify(name, number) do
    struct(__MODULE__, name: name, number: parse_number(number))
  end

  defp parse_number(nil) do
    nil
  end

  defp parse_number("") do
    nil
  end

  defp parse_number(number) when is_binary(number) do
    cond do
      {float, ""} = Float.parse(number) -> Float.round(float, 2)
      true -> nil
    end
    |> integerize()
  end

  defp parse_number(number) when is_integer(number) or is_float(number) do
    number
  end

  defp integerize(number) do
    if number && number == Float.round(number) do
      number
      |> round()
    else
      number
    end
  end
end
