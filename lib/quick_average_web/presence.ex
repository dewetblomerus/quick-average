defmodule QuickAverageWeb.Presence do
  alias QuickAverage.Users
  alias QuickAverage.DisplayState

  use Phoenix.Presence,
    otp_app: :my_app,
    pubsub_server: QuickAverage.PubSub

  def init(_opts) do
    # user-land state
    {:ok, %{}}
  end

  def handle_metas(room_id, _joins_leaves, presences, state) do
    users = Users.from_presences(presences)

    broadcast(display_topic(room_id), %DisplayState{users: users})

    {:ok, state}
  end

  def display_topic(room_id) do
    "#{room_id}_display"
  end

  def broadcast(topic, message) do
    Phoenix.PubSub.local_broadcast(
      QuickAverage.PubSub,
      topic,
      message
    )
  end
end
