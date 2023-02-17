defmodule QuickAverage.Presence.Interface do
  alias QuickAverage.{
    DisplayState,
    Presence,
    User
  }

  def display_state(room_id) do
    room_id
    |> Presence.list()
    |> DisplayState.from_presences()
  end

  defdelegate list(room_id), to: Presence

  def update(
        socket,
        %{"name" => _name} = user_params
      ) do
    Presence.update(
      self(),
      socket.assigns.room_id,
      socket.id,
      %{user: User.from_params(user_params)}
    )
  end

  def track(socket) do
    Presence.track(
      self(),
      socket.assigns.room_id,
      socket.id,
      %{user: User.from_params(%{"name" => "Anonymous", "number" => nil})}
    )
  end
end
