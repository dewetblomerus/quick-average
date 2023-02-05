defmodule QuickAverage.DisplayStateTest do
  use ExUnit.Case, async: true
  alias QuickAverage.DisplayState
  alias QuickAverage.User

  @users [
    %{
      name: "Bob",
      number: "3"
    },
    %{
      name: "De Wet",
      number: "1"
    }
  ]

  @display_state %DisplayState{
    users: [
      %User{
        name: "Bob",
        number: 3
      },
      %User{
        name: "De Wet",
        number: 1
      }
    ],
    average: 2
  }

  describe("from_users/1") do
    test "shows the numbers when all are available" do
      assert DisplayState.from_users(@users) == @display_state
    end
  end
end
