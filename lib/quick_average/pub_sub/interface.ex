defmodule QuickAverage.PubSub.Interface do
  def subscribe_display(room_id) do
    Phoenix.PubSub.subscribe(
      QuickAverage.PubSub,
      display_topic(room_id)
    )
  end

  def broadcast(room_id, message) do
    Phoenix.PubSub.local_broadcast(
      QuickAverage.PubSub,
      display_topic(room_id),
      message
    )
  end

  defp display_topic(room_id) do
    "#{room_id}_display"
  end
end
