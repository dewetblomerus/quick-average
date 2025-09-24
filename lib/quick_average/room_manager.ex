defmodule QuickAverage.RoomManager do
  require Logger
  use GenServer
  alias QuickAverage.DisplayState
  alias QuickAverage.Presence.Interface, as: PresenceInterface
  alias QuickAverage.PubSub.Interface, as: PubSubInterface
  alias QuickAverage.RoomManager.SupervisorInterface

  @refresh_delay 50

  def start_link(room_id) when is_binary(room_id) do
    GenServer.start_link(__MODULE__, room_id, name: name(room_id))
  end

  @impl true
  def init(room_id) do
    Logger.info("Starting RoomManager for #{room_id} 🤖")
    presences = PresenceInterface.list(room_id)
    is_revealed_manually = false
    sort_by_number = false

    display_state =
      DisplayState.from_input_state(%{
        presences: presences,
        is_revealed_manually: is_revealed_manually,
        sort_by_number: false
      })

    state = %{
      display_state: display_state,
      room_id: room_id,
      presences: presences,
      is_revealed_manually: is_revealed_manually,
      sort_by_number: sort_by_number,
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
        %{
          version: version,
          display_version: display_version,
          is_revealed_manually: is_revealed_manually,
          sort_by_number: sort_by_number,
          presences: presences
        } = state
      )
      when version > display_version do
    :telemetry.execute([:quick_average, :update_display], %{
      event: "update_display",
      room_id: state.room_id
    })

    %DisplayState{users: users} =
      display_state =
      DisplayState.from_input_state(%{
        presences: presences,
        is_revealed_manually: is_revealed_manually,
        sort_by_number: sort_by_number
      })

    if Enum.empty?(users) do
      Logger.info("No users left, stopping RoomManager for #{state.room_id} 🤖")
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
  def handle_call({:set_reveal, is_revealed} = message, _from, state)
      when is_boolean(is_revealed) do
    new_state = %{
      state
      | is_revealed_manually: is_revealed,
        version: state.version + 1
    }

    PubSubInterface.broadcast(
      state.room_id,
      message
    )

    {:reply, :ok, new_state}
  end

  @impl true
  def handle_call({:send_flash, level, message}, _from, state) do
    PubSubInterface.broadcast(
      state.room_id,
      {:show_flash, level, message}
    )

    {:reply, :ok, state}
  end

  @impl true
  def handle_call({:sort_by_number, sort_by_number} = message, _from, state) do
    new_state = %{
      state
      | sort_by_number: sort_by_number,
        version: state.version + 1
    }

    PubSubInterface.broadcast(
      state.room_id,
      message
    )

    {:reply, :ok, new_state}
  end

  @impl true
  def handle_cast(%{presences: presences}, state) do
    :telemetry.execute([:quick_average, :presences_received], %{
      event: "presences_received",
      room_id: state.room_id
    })

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

  def toggle_reveal(room_id, name) do
    GenServer.call(
      name(room_id),
      {:toggle_reveal, name}
    )
  end

  def set_reveal(room_id, is_revealed) when is_boolean(is_revealed) do
    GenServer.call(
      name(room_id),
      {:set_reveal, is_revealed}
    )
  end

  def send_flash(room_id, level, message) do
    GenServer.call(
      name(room_id),
      {:send_flash, level, message}
    )
  end

  def set_sort_by_number(room_id, sort_by_number) do
    GenServer.call(
      name(room_id),
      {:sort_by_number, sort_by_number}
    )
  end

  defp name(room_id), do: {:via, Registry, {QuickAverage.Registry, room_id}}
end
