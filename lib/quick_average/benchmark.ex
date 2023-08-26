defmodule QuickAverage.Benchmark do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  @fields [:room_id, :amount]

  embedded_schema do
    field(:room_id, :string)
    field(:amount, :integer)
  end

  @doc false
  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, @fields)
    |> validate_required(:room_id)
    |> validate_length(:room_id, max: 25)
    |> validate_number(:amount, less_than: 1_000_000, greater_than: -1)
  end

  def from_params(params) do
    clean_params = changeset(params).changes()
    struct(__MODULE__, clean_params)
  end
end
