defmodule QuickAverage.UsersTest do
  alias QuickAverage.Users
  use ExUnit.Case, async: true

  @presences %{
    "phx-F0BfS5VmmAjGVQAp" => [
      %{
        :phx_ref => "F0BfyHLOTZXf-gBl",
        :phx_ref_prev => "F0BfyHBOLAzf-gAE",
        "name" => "De Wet",
        "number" => "9"
      }
    ],
    "phx-F0Bfyj6AREQQNwAi" => [
      %{
        :phx_ref => "F0Bfy08QWAzf-gEF",
        :phx_ref_prev => "F0Bfy0fqQkHf-gDl",
        "name" => "Bob",
        "number" => "99"
      }
    ]
  }

  @users [
    %{
      name: "De Wet",
      number: "9"
    },
    %{
      name: "Bob",
      number: "99"
    }
  ]

  test("generate/1") do
    assert Users.from_presences(@presences) == @users
  end
end
