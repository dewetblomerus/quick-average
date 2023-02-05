defmodule QuickAverage.UserTest do
  alias QuickAverage.User
  use ExUnit.Case, async: true

  def params(number \\ 5) do
    %{name: "De Wet", number: number}
  end

  describe("from_params/1") do
    test("correctly formatted user is unchanged") do
      assert %User{name: "De Wet", number: 5} = params() |> User.from_params()
    end

    test("string keys are atomized") do
      assert %User{name: "De Wet", number: 5} =
               User.from_params(%{"name" => "De Wet", "number" => 5})
    end

    test("Whole string number is converted to an integer") do
      assert %User{name: "De Wet", number: 5} =
               "5"
               |> params()
               |> User.from_params()
    end

    test("Float number is unchanged") do
      assert %User{name: "De Wet", number: 5.1} =
               "5.1"
               |> params()
               |> User.from_params()
    end

    test("Float string number is converted to a float") do
      assert %User{name: "De Wet", number: 5.5} =
               "5.5"
               |> params()
               |> User.from_params()
    end

    test("Float string number is rounded to 2 place values") do
      assert %User{name: "De Wet", number: 5.56} =
               "5.5555"
               |> params()
               |> User.from_params()
    end

    test("nil number stays nil") do
      assert %User{name: "De Wet", number: nil} =
               nil
               |> params()
               |> User.from_params()
    end
  end
end
