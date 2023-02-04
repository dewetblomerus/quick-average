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

  @presence_list %{
    "phx-F0CZi2iBCzv8twKk" => %{
      metas: [
        %{
          :phx_ref => "F0CZi2iBn1cM0ADl",
          "name" => "De Wet",
          "number" => "9"
        }
      ]
    },
    "phx-F0Bfyj6AREQQNwAi" => %{
      metas: [
        %{
          :phx_ref => "F0Bfy08QWAzf-gEF",
          :phx_ref_prev => "F0Bfy0fqQkHf-gDl",
          "name" => "Bob",
          "number" => "99"
        },
        %{another: "ignored meta"}
      ]
    }
  }

  @users [
    %{
      name: "Bob",
      number: "99"
    },
    %{
      name: "De Wet",
      number: "9"
    }
  ]

  describe("from_presences/1") do
    test("with presences") do
      assert Users.from_presences(@presences) == @users
    end

    test("with a presence_list") do
      assert Users.from_presences(@presence_list) == @users
    end
  end
end
