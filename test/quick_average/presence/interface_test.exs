defmodule QuickAverage.Presence.InterfaceTest do
  use ExUnit.Case, async: true
  alias QuickAverage.Presence
  alias QuickAverage.Presence.Interface
  import Mimic

  describe("list_users/1") do
    test("returns display state for a room_id") do
      assert %QuickAverage.DisplayState{} = Interface.list_users("5")
    end
  end

  describe("update/2") do
    setup :set_mimic_private

    test("updates the Presence") do
      Presence
      |> expect(:update, fn pid, room_id, socket_id, params ->
        [pid, room_id, socket_id, params]
      end)

      parent_pid = self()
      user_params = %{"name" => "De Wet", "number" => "42"}

      spawn_link(fn ->
        Presence |> allow(parent_pid, self())
        my_pid = self()

        assert [
                 my_pid,
                 "room_id",
                 "socket_id",
                 user_params
               ] ==
                 Interface.update(
                   %{id: "socket_id", assigns: %{room_id: "room_id"}},
                   user_params
                 )

        send(parent_pid, :ok)
      end)

      assert_receive :ok
    end
  end

  describe("track/1") do
    setup :set_mimic_private

    test("gets tracked by the Presence") do
      Presence
      |> expect(:track, fn pid, room_id, socket_id, params ->
        [pid, room_id, socket_id, params]
      end)

      parent_pid = self()

      spawn_link(fn ->
        Presence |> allow(parent_pid, self())
        my_pid = self()

        assert [
                 my_pid,
                 "room_id",
                 "socket_id",
                 %{"name" => "Anonymous", "number" => nil}
               ] ==
                 Interface.track(%{
                   id: "socket_id",
                   assigns: %{room_id: "room_id"}
                 })

        send(parent_pid, :ok)
      end)

      assert_receive :ok
    end
  end
end
