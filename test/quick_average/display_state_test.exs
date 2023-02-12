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

  describe("from_presences/1 with all numbers present") do
    setup do
      %{users: @users}
    end

    test("generates display state from presences", %{users: users}) do
      assert users
             |> Factory.presences_for()
             |> DisplayState.from_presences() ==
               @display_state
    end

    test("generates display state from a presence_list", %{users: users}) do
      assert users
             |> Factory.presence_list_for()
             |> DisplayState.from_presences() ==
               @display_state
    end
  end

  describe("from_presences/1 without all numbers present") do
    setup do
      presences =
        [
          %QuickAverage.User{name: "De Wet", number: 42},
          %QuickAverage.User{name: "Nildecided", number: nil},
          %QuickAverage.User{name: "Undecided", number: ""}
        ]
        |> Factory.presences_for()

      %{presences: presences}
    end

    test("the average is Waiting", %{
      presences: presences
    }) do
      assert presences
             |> DisplayState.from_presences()
             |> Map.get(:average) ==
               "Waiting"
    end

    test("the users with missing numbers displays a Waiting number", %{
      presences: presences
    }) do
      expected_users = [
        %QuickAverage.User{name: "De Wet", number: "Hidden"},
        %QuickAverage.User{name: "Nildecided", number: "Waiting"},
        %QuickAverage.User{name: "Undecided", number: "Waiting"}
      ]

      assert presences
             |> DisplayState.from_presences()
             |> Map.get(:users) ==
               expected_users
    end
  end
end
