defmodule QuickAverage.RoomManager do
  require Logger
  use GenServer
  alias QuickAverage.RoomManager.SupervisorInterface
  alias QuickAverage.Presence.Interface, as: PresenceInterface
  alias QuickAverage.PubSub.Interface, as: PubSubInterface
  alias QuickAverage.DisplayState

  @refresh_delay 50
  @idle_seconds_before_stop 10

  def start_link(room_id) when is_binary(room_id) do
    GenServer.start_link(__MODULE__, room_id, name: name(room_id))
  end

  @impl true
  def init(room_id) do
    Logger.info("Starting RoomManager for #{room_id} 🤖")
    presences = PresenceInterface.list(room_id)

    state = %{
      display_state: DisplayState.from_presences(presences),
      room_id: room_id,
      presences: presences,
      start_time: now(),
      version: 0,
      display_version: 0
    }

    Process.send_after(self(), :update, 1)

    {:ok, state}
  end

  @impl true
  def handle_info(
        :update,
        %{version: version, display_version: display_version} = state
      )
      when version > display_version do
    %DisplayState{users: users} =
      display_state = DisplayState.from_presences(state.presences)

    if length(users) == 0 do
      IO.puts("No users left, stopping RoomManager for #{state.room_id} 🤖")
      SupervisorInterface.delete(self())
    end

    PubSubInterface.broadcast(state.room_id, display_state)

    Process.send_after(self(), :update, @refresh_delay)

    {:noreply,
     %{state | display_state: display_state, display_version: version}}
  end

  @impl true
  def handle_info(:update, state) do
    Process.send_after(self(), :update, @refresh_delay)
    {:noreply, state}
  end

  @impl true
  def handle_call(:display_state, _from, state) do
    {:reply, state.display_state, state}
  end

  @impl true
  def handle_cast(%{presences: presences}, state) do
    new_state =
      state
      |> Map.update!(:version, &(&1 + 1))
      |> Map.put(:presences, presences)

    {:noreply, new_state}
  end

  defp now, do: DateTime.now!("Etc/UTC") |> DateTime.to_unix()

  def get_display_state(room_id) do
    GenServer.call(
      name(room_id),
      :display_state
    )
  end

  def set_presences(room_id, presences) do
    GenServer.cast(
      name(room_id),
      %{presences: presences}
    )
  end

  defp name(room_id), do: {:via, Registry, {QuickAverage.Registry, room_id}}
end
