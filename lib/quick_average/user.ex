defmodule QuickAverage.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  @fields [:name, :number, :only_viewing]

  embedded_schema do
    field(:name, :string)
    field(:number, :float)
    field(:only_viewing, :boolean, default: false)
  end

  @doc false
  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, @fields)
    |> validate_required(:name)
    |> validate_length(:name, max: 25)
    |> validate_number(:number, less_than: 1_000_000, greater_than: -1_000_000)
  end

  def from_params(params) do
    clean_params = changeset(params).changes()
    struct(__MODULE__, clean_params)
  end
end
