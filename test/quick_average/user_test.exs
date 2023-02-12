defmodule QuickAverage.UserTest do
  alias QuickAverage.User
  use ExUnit.Case, async: true

  describe("from_params/1") do
    test("correctly formatted user is unchanged") do
      assert %User{name: "De Wet", number: 5, only_viewing: false} ==
               User.from_params(%{
                 name: "De Wet",
                 number: 5,
                 only_viewing: false
               })
    end

    test("string keys are atomized") do
      assert %User{name: "De Wet", number: 5.5555, only_viewing: true} ==
               User.from_params(%{
                 "name" => "De Wet",
                 "number" => "5.5555",
                 "only_viewing" => "true"
               })
    end

    test("have sensible defaults when only a name is given") do
      assert %User{name: "De Wet", number: nil, only_viewing: false} ==
               User.from_params(%{"name" => "De Wet"})
    end
  end
end
