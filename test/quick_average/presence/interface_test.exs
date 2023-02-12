defmodule QuickAverage.Presence.InterfaceTest do
  use ExUnit.Case, async: true
  alias QuickAverage.{Presence, User}
  alias QuickAverage.Presence.Interface
  import Mimic

  describe("display_state/1") do
    test("returns display state for a room_id") do
      assert %QuickAverage.DisplayState{} = Interface.display_state("5")
    end
  end

  describe("update/2") do
    setup :set_mimic_private

    test("updates the Presence of a user with a number") do
      Presence
      |> expect(:update, fn pid, room_id, socket_id, params ->
        [pid, room_id, socket_id, params]
      end)

      parent_pid = self()
      raw_params = %{"name" => "De Wet", "number" => "42"}
      presence_data = %{user: User.from_params(raw_params)}

      spawn_link(fn ->
        Presence |> allow(parent_pid, self())
        my_pid = self()

        assert [
                 my_pid,
                 "room_id",
                 "socket_id",
                 presence_data
               ] ==
                 Interface.update(
                   %{id: "socket_id", assigns: %{room_id: "room_id"}},
                   raw_params
                 )

        send(parent_pid, :ok)
      end)

      assert_receive :ok
    end

    test("updates the Presence of a viewing user") do
      Presence
      |> expect(:update, fn pid, room_id, socket_id, params ->
        [pid, room_id, socket_id, params]
      end)

      parent_pid = self()
      raw_params = %{"name" => "De Wet", "only_viewing" => "true"}
      presence_data = %{user: User.from_params(raw_params)}

      spawn_link(fn ->
        Presence |> allow(parent_pid, self())
        my_pid = self()

        assert [
                 my_pid,
                 "room_id",
                 "socket_id",
                 presence_data
               ] ==
                 Interface.update(
                   %{id: "socket_id", assigns: %{room_id: "room_id"}},
                   raw_params
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

      raw_params = %{"name" => "Anonymous", "number" => nil}
      presence_data = %{user: User.from_params(raw_params)}

      spawn_link(fn ->
        Presence |> allow(parent_pid, self())
        my_pid = self()

        assert [
                 my_pid,
                 "room_id",
                 "socket_id",
                 presence_data
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
