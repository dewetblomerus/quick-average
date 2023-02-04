defmodule QuickAverage.User do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:name, :string)
    field(:number, :integer)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :number])
    |> validate_required([:name, :number])
  end
end
