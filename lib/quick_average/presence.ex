defmodule QuickAverage.Presence do
  alias QuickAverage.PubSub.Interface, as: PubSubInterface
  alias QuickAverage.RoomManager

  use Phoenix.Presence,
    otp_app: :my_app,
    pubsub_server: QuickAverage.PubSub

  def init(_opts) do
    # user-land state
    {:ok, %{}}
  end

  def handle_metas(room_id, _joins_leaves, presences, state) do
    RoomManager.set_presences(room_id, presences)

    {:ok, state}
  end
end
