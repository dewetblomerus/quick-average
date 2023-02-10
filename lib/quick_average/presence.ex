defmodule QuickAverage.Presence do
  alias QuickAverage.DisplayState

  use Phoenix.Presence,
    otp_app: :my_app,
    pubsub_server: QuickAverage.PubSub

  def init(_opts) do
    # user-land state
    {:ok, %{}}
  end

  def handle_metas(room_id, _joins_leaves, presences, state) do
    display_state =
      presences
      |> DisplayState.from_presences()

    broadcast(room_id, display_state)

    {:ok, state}
  end

  def display_topic(room_id) do
    "#{room_id}_display"
  end

  def broadcast(room_id, message) do
    topic = display_topic(room_id)

    Phoenix.PubSub.local_broadcast(
      QuickAverage.PubSub,
      topic,
      message
    )
  end
end
