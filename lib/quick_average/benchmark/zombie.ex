defmodule QuickAverage.Benchmark.Zombie do
  use GenServer

  def start_link(room_id) when is_binary(room_id) do
    GenServer.start_link(__MODULE__, room_id)
  end

  def room_id(pid) do
    GenServer.call(pid, :room_id)
  end

  def init(init_arg) do
    {:ok, init_arg}
  end

  def handle_call(:room_id, _, state) do
    {:reply, state, state}
  end
end
