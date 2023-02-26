defmodule QuickAverage.Presence.Interface do
  alias QuickAverage.{
    Presence,
    User
  }

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
