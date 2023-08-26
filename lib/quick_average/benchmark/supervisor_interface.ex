defmodule QuickAverage.Benchmark.SupervisorInterface do
  require Logger
  alias QuickAverage.Benchmark.Zombie

  @genserver Zombie
  @supervisor QuickAverage.BenchmarkSupervisor

  def implement(room_id, required_amount)
      when is_binary(room_id) and is_integer(required_amount) do
    # delete all zombies that have a different room_id
    children()
    |> Enum.each(fn {:undefined, zombie_pid, _, _} ->
      zombie_room_id = Zombie.room_id(zombie_pid)

      case zombie_room_id do
        ^room_id -> true
        _ -> delete(zombie_pid)
      end
    end)

    # calculate the difference between the required amount and the number of zombies
    diff = required_amount - count_children()

    case diff do
      # if the difference is positive, create that many zombies
      diff when diff > 0 -> Enum.each(1..diff, fn _ -> start_child(room_id) end)
      # if the difference is negative, delete that many zombies
      diff when diff < 0 -> Enum.each(-1..diff, fn _ -> delete_one() end)
      0 -> true
    end

    dbg(count_children())
  end

  def start_child(room_id) do
    DynamicSupervisor.start_child(
      @supervisor,
      {@genserver, room_id}
    )
  end

  def children do
    DynamicSupervisor.which_children(@supervisor)
  end

  def count_children do
    Enum.count(children())
  end

  def delete_one do
    delete(first_child_pid())
  end

  def delete(pid) do
    DynamicSupervisor.terminate_child(@supervisor, pid)
  end

  def first_child_pid do
    [{_, pid, _, _} | _] =
      DynamicSupervisor.which_children(QuickAverage.BenchmarkSupervisor)

    pid
  end
end
