defmodule QuickAverage.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias QuickAverage.DisplayNumber

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
    struct(__MODULE__, name: name, number: DisplayNumber.parse(number))
  end
end
