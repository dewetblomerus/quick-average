defmodule QuickAverage.DisplayStateTest do
  use ExUnit.Case, async: true
  alias QuickAverage.DisplayState
  alias QuickAverage.User

  @presences %{
    "phx-F0BfS5VmmAjGVQAp" => [
      %{
        phx_ref: "F0BfyHLOTZXf-gBl",
        phx_ref_prev: "F0BfyHBOLAzf-gAE",
        user: %User{
          name: "De Wet",
          number: 9
        }
      }
    ],
    "phx-F0Bfyj6AREQQNwAi" => [
      %{
        phx_ref: "F0Bfy08QWAzf-gEF",
        phx_ref_prev: "F0Bfy0fqQkHf-gDl",
        user: %User{
          name: "Bob",
          number: 99
        }
      }
    ]
  }

  @presence_list %{
    "phx-F0CZi2iBCzv8twKk" => %{
      metas: [
        %{
          phx_ref: "F0CZi2iBn1cM0ADl",
          user: %User{
            name: "De Wet",
            number: 9
          }
        }
      ]
    },
    "phx-F0Bfyj6AREQQNwAi" => %{
      metas: [
        %{
          phx_ref: "F0Bfy08QWAzf-gEF",
          phx_ref_prev: "F0Bfy0fqQkHf-gDl",
          user: %User{
            name: "Bob",
            number: 99
          }
        },
        %{another: "ignored meta"}
      ]
    }
  }

  @display_state %DisplayState{
    users: [
      %User{
        name: "Bob",
        number: 99
      },
      %User{
        name: "De Wet",
        number: 9
      }
    ],
    average: 54
  }

  describe("from_presences/1") do
    test("with presences") do
      assert DisplayState.from_presences(@presences) == @display_state
    end

    test("with a presence_list") do
      assert DisplayState.from_presences(@presence_list) == @display_state
    end
  end
end
