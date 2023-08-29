defmodule QuickAverage.Benchmark.Zombie do
  use GenServer
  alias QuickAverage.PubSub.Interface, as: PubSubInterface
  alias QuickAverage.Presence.Interface, as: PresenceInterface

  def start_link(room_id) when is_binary(room_id) do
    GenServer.start_link(__MODULE__, room_id)
  end

  def room_id(pid) do
    GenServer.call(pid, :room_id)
  end

  def init(room_id) when is_binary(room_id) do
    PubSubInterface.subscribe_display(room_id)
    zombie_id = id(room_id)
    zombie_socket = %{id: zombie_id, assigns: %{room_id: room_id}}
    PresenceInterface.track(zombie_socket)

    {:ok, room_id}
  end

  def handle_call(:room_id, _, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_info(
        %QuickAverage.DisplayState{
          users: users,
          average: _average
        },
        state
      ) do
    {:noreply, state}
  end

  @impl true
  def handle_info({:clear_number, clearer_name}, state) do
    dbg(clearer_name)

    {:noreply, state}
  end

  def id(room_id) do
    pid_string = self() |> :erlang.pid_to_list() |> to_string()

    "#{room_id}-#{pid_string}"
  end
end
