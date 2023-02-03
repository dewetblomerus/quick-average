defmodule QuickAverageWeb.Presence do
  alias QuickAverage.Users

  use Phoenix.Presence,
    otp_app: :my_app,
    pubsub_server: QuickAverage.PubSub

  def init(_opts) do
    # user-land state
    {:ok, %{}}
  end

  def handle_metas(topic, %{joins: joins, leaves: leaves}, presences, state) do
    presences
    |> Users.from_presences()
    |> dbg()

    {:ok, state}
  end
end
