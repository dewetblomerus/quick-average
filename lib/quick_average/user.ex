defmodule QuickAverage.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias QuickAverage.DisplayNumber

  @primary_key false
  @fields [:name, :number]

  embedded_schema do
    field(:name, :string)
    field(:number, :float)
  end

  @doc false
  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:name, :number])
    |> validate_required([:name, :number])
  end

  def from_params(%{name: name, number: number}) do
    structify(name, number)
  end

  def from_params(%{"name" => name, "number" => number}) do
    structify(name, number)
  end

  def from_params(%{"name" => name}) do
    structify(name, nil)
  end

  def to_params(%__MODULE__{} = user) do
    user
    |> Map.from_struct()
    |> Map.take(@fields)
    |> Map.new(fn {k, v} -> {Atom.to_string(k), v} end)
  end

  def structify(name, number) do
    struct(__MODULE__, name: name, number: DisplayNumber.parse(number))
  end
end
