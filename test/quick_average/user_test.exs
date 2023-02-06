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

    test("string keys are atomized and number is parsed") do
      assert %User{name: "De Wet", number: 5.56} ==
               User.from_params(%{"name" => "De Wet", "number" => "5.5555"})
    end

    test("works with only a name") do
      assert %User{name: "De Wet", number: "Waiting"} ==
               User.from_params(%{"name" => "De Wet"})
    end
  end

  describe("to_params/1") do
    test("converts back to params") do
      assert %User{name: "De Wet", number: 5} |> User.to_params() == %{
               "name" => "De Wet",
               "number" => 5
             }
    end

    test("string keys are atomized and number is parsed") do
      assert %User{name: "De Wet", number: 5.56} =
               User.from_params(%{"name" => "De Wet", "number" => "5.5555"})
    end
  end
end
