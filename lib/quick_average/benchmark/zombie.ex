defmodule QuickAverage.Benchmark.Zombie do
  use GenServer
  alias QuickAverage.PubSub.Interface, as: PubSubInterface
  alias QuickAverage.Presence.Interface, as: PresenceInterface

  @update_in 1000

  def start_link(room_id) when is_binary(room_id) do
    GenServer.start_link(__MODULE__, room_id)
  end

  def room_id(pid) do
    GenServer.call(pid, :room_id)
  end

  def init(room_id) when is_binary(room_id) do
    PubSubInterface.subscribe_display(room_id)
    zombie_socket = zombie_socket(room_id)

    room_id
    |> zombie_socket()
    |> PresenceInterface.track()

    Process.send_after(self(), :update, @update_in)

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
  def handle_info(:update, state) do
    state
    |> zombie_socket()
    |> PresenceInterface.update(%{"name" => name(), "number" => number()})

    Process.send_after(self(), :update, @update_in)
    {:noreply, state}
  end

  @impl true
  def handle_info({:set_reveal, _, _}, state) do
    {:noreply, state}
  end

  @impl true
  def handle_info({:clear_number, clearer_name}, state) do
    dbg(clearer_name)

    {:noreply, state}
  end

  defp zombie_socket(room_id) do
    %{id: id(room_id), assigns: %{room_id: room_id}}
  end

  defp id(room_id) do
    pid_string = self() |> :erlang.pid_to_list() |> to_string()

    "#{room_id}-#{pid_string}"
  end

  defp name do
    [
      "Yoda",
      "Luke Skywalker",
      "Darth Vader",
      "Princess Leiah",
      "Obi-Wan Kenobi"
    ]
    |> Enum.random()
  end

  defp number do
    Enum.random(1..100)
  end
end
