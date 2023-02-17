defmodule QuickAverage.RoomManager.SupervisorInterface do
  require Logger

  @genserver QuickAverage.RoomManager
  @supervisor QuickAverage.RoomManagerSupervisor

  def create(room_id) do
    DynamicSupervisor.start_child(
      @supervisor,
      {@genserver, room_id}
    )
  end

  def children do
    DynamicSupervisor.which_children(@supervisor)
  end

  def delete(pid) do
    DynamicSupervisor.terminate_child(@supervisor, pid)
  end
end
