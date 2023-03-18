defmodule QuickAverage.DisplayStateTest do
  use ExUnit.Case, async: true
  alias QuickAverage.DisplayState
  alias QuickAverage.User
  alias Support.Factory

  @users [
    %User{
      name: "Bob",
      number: 99,
      only_viewing: false
    },
    %User{
      name: "De Wet",
      number: 9,
      only_viewing: false
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
             |> Factory.input_state_for()
             |> DisplayState.from_input_state() ==
               @display_state
    end

    test("generates display state from a presence_list", %{users: users}) do
      assert users
             |> Factory.input_state_for()
             |> DisplayState.from_input_state() ==
               @display_state
    end
  end

  describe(
    "from_input_state/1 with someone viewing and all other numbers present"
  ) do
    setup do
      input_users =
        [
          %User{name: "Manager", number: nil, only_viewing: true} | @users
        ]
        |> Enum.sort()

      display_users =
        [
          %User{name: "Manager", number: :viewing, only_viewing: true} | @users
        ]
        |> Enum.sort()

      %{
        input_users: input_users,
        display_users: display_users
      }
    end

    test("generates display state from presences", %{
      input_users: input_users,
      display_users: display_users
    }) do
      assert input_users
             |> Factory.input_state_for()
             |> DisplayState.from_input_state() ==
               %DisplayState{
                 users: display_users,
                 average: 54
               }
    end
  end

  describe("from_presences/1 without all numbers present") do
    setup do
      input_state =
        [
          %QuickAverage.User{name: "De Wet", number: 42},
          %QuickAverage.User{name: "Nildecided", number: nil},
          %QuickAverage.User{name: "Undecided", number: ""}
        ]
        |> Factory.input_state_for()

      %{input_state: input_state}
    end

    test("the average is Waiting", %{
      input_state: input_state
    }) do
      assert input_state
             |> DisplayState.from_input_state()
             |> Map.get(:average) ==
               "Waiting"
    end

    test("the users with missing numbers displays a Waiting number", %{
      input_state: input_state
    }) do
      expected_users = [
        %QuickAverage.User{name: "De Wet", number: :hidden},
        %QuickAverage.User{name: "Nildecided", number: :waiting},
        %QuickAverage.User{name: "Undecided", number: :waiting}
      ]

      assert input_state
             |> DisplayState.from_input_state()
             |> Map.get(:users) ==
               expected_users
    end
  end

  describe("from_presences/1 without all numbers present but reveal clicked") do
    setup do
      presences =
        [
          %QuickAverage.User{name: "De Wet", number: 42},
          %QuickAverage.User{name: "Nildecided", number: nil},
          %QuickAverage.User{name: "Undecided", number: ""}
        ]
        |> Factory.presences_for()

      %{input_state: %{presences: presences, manual_reveal: true}}
    end

    test("the average is Waiting", %{
      input_state: input_state
    }) do
      assert input_state
             |> DisplayState.from_input_state()
             |> Map.get(:average) ==
               42
    end

    test("the users with missing numbers displays a Waiting number", %{
      input_state: input_state
    }) do
      expected_users = [
        %QuickAverage.User{name: "De Wet", number: 42},
        %QuickAverage.User{name: "Nildecided", number: :waiting},
        %QuickAverage.User{name: "Undecided", number: :waiting}
      ]

      assert input_state
             |> DisplayState.from_input_state()
             |> Map.get(:users) ==
               expected_users
    end
  end

  describe("from_presences/1 without no numbers present but reveal clicked") do
    setup do
      presences =
        [
          %QuickAverage.User{name: "De Wet", number: nil},
          %QuickAverage.User{name: "Nildecided", number: nil},
          %QuickAverage.User{name: "Undecided", number: nil}
        ]
        |> Factory.presences_for()

      %{input_state: %{presences: presences, manual_reveal: true}}
    end

    test("the average is Waiting", %{
      input_state: input_state
    }) do
      assert input_state
             |> DisplayState.from_input_state()
             |> Map.get(:average) ==
               "Waiting"
    end
  end
end
