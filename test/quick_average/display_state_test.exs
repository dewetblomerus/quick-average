defmodule QuickAverage.DisplayStateTest do
  use ExUnit.Case, async: true
  alias QuickAverage.DisplayState
  alias QuickAverage.User
  alias Support.Factory

  @users [
    %User{
      name: "Bob",
      number: 99
    },
    %User{
      name: "De Wet",
      number: 9
    }
  ]

  @display_state %DisplayState{
    users: @users,
    average: 54
  }

  describe("from_presences/1") do
    test("with presences") do
      assert @users
             |> Factory.presences_for()
             |> DisplayState.from_presences() ==
               @display_state
    end

    test("with a presence_list") do
      assert @users
             |> Factory.presence_list_for()
             |> DisplayState.from_presences() ==
               @display_state
    end
  end
end
