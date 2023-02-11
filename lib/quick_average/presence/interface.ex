defmodule QuickAverage.Presence.Interface do
  alias QuickAverage.{
    DisplayState,
    Presence,
    User
  }

  def list_users(room_id) do
    room_id
    |> Presence.list()
    |> DisplayState.from_presences()
  end

  def update(
        socket,
        %{"name" => _name, "number" => _number} = user_params
      ) do
    Presence.update(
      self(),
      socket.assigns.room_id,
      socket.id,
      %{user: User.from_params(user_params)}
    )
  end

  defdelegate broadcast(room_id, message), to: Presence

  def track(socket) do
    Presence.track(
      self(),
      socket.assigns.room_id,
      socket.id,
      %{user: User.from_params(%{"name" => "Anonymous", "number" => nil})}
    )
  end

  def subscribe_display(room_id) do
    Phoenix.PubSub.subscribe(
      QuickAverage.PubSub,
      Presence.display_topic(room_id)
    )
  end
end