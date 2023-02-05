defmodule QuickAverage.DisplayNumberTest do
  alias QuickAverage.DisplayNumber
  use ExUnit.Case, async: true

  describe("parse/1") do
    test("integer is unchanged") do
      assert DisplayNumber.parse(5) == 5
    end

    test("Whole string number is converted to an integer") do
      assert DisplayNumber.parse("5") == 5
    end

    test("Float number is unchanged") do
      assert DisplayNumber.parse(5.1) == 5.1
    end

    test("Float string number is converted to a float") do
      assert DisplayNumber.parse("5.1") == 5.1
    end

    test("Float string number is rounded to 2 place values") do
      assert DisplayNumber.parse("5.5555") == 5.56
    end

    test("nil number syas Waiting") do
      assert DisplayNumber.parse(nil) == "Waiting"
    end

    test("empty string syas Waiting") do
      assert DisplayNumber.parse("") == "Waiting"
    end
  end
end
