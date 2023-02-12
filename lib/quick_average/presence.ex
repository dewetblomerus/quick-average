defmodule QuickAverage.Presence do
  alias QuickAverage.DisplayState
  alias QuickAverage.PubSub.Interface, as: PubSubInterface

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

    PubSubInterface.broadcast(room_id, display_state)

    {:ok, state}
  end
end
