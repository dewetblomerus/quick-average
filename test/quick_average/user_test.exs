defmodule QuickAverage.UserTest do
  alias QuickAverage.User
  use ExUnit.Case, async: true

  def params(number \\ 5) do
    %{name: "De Wet", number: number}
  end

  describe("from_params/1") do
    test("correctly formatted user is unchanged") do
      assert %User{name: "De Wet", number: 5} == params() |> User.from_params()
    end

    test("string keys are atomized") do
      assert %User{name: "De Wet", number: 5.5555} ==
               User.from_params(%{"name" => "De Wet", "number" => "5.5555"})
    end

    test("works with only a name") do
      assert %User{name: "De Wet", number: nil} ==
               User.from_params(%{"name" => "De Wet"})
    end
  end
end
