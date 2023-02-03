defmodule QuickAverageWeb.Presence do
  alias QuickAverage.Users

  use Phoenix.Presence,
    otp_app: :my_app,
    pubsub_server: QuickAverage.PubSub

  def init(_opts) do
    # user-land state
    {:ok, %{}}
  end

  def handle_metas(room_id, _joins_leaves, presences, state) do
    users = Users.from_presences(presences)

    Phoenix.PubSub.local_broadcast(
      QuickAverage.PubSub,
      display_topic(room_id),
      %{users: users}
    )

    {:ok, state}
  end

  def display_topic(room_id) do
    "#{room_id}_display"
  end
end
