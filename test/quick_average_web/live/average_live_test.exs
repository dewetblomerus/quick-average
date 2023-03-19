defmodule QuickAverageWeb.AverageLiveTest do
  use QuickAverageWeb.ConnCase
  alias Support.Factory

  alias QuickAverage.{
    DisplayState,
    Presence,
    User
  }

  alias QuickAverage.RoomManager.SupervisorInterface,
    as: ManagerSupervisor

  import Mimic
  import Phoenix.LiveViewTest

  @create_attrs %{name: "some name", number: 42}

  describe "Index" do
    setup do
      room_id = "#{Enum.random(1..100)}"

      trackable_user = %{
        user: User.from_params(%{"name" => "Anonymous", "number" => nil})
      }

      expect(
        Presence,
        :track,
        fn _, ^room_id, _, ^trackable_user -> :ok end
      )

      expect(ManagerSupervisor, :create, fn ^room_id -> :ok end)

      expect(Phoenix.PubSub, :subscribe, fn QuickAverage.PubSub, _ ->
        :ok
      end)

      %{room_id: room_id}
    end

    test "sets up tracking and subscribing", %{conn: conn, room_id: room_id} do
      {:ok, _index_live, _html} = live(conn, ~p"/#{room_id}")
      verify!()
    end

    test "renders the form", %{conn: conn, room_id: room_id} do
      {:ok, _index_live, html} = live(conn, ~p"/#{room_id}")

      assert html =~ "Name"
      assert html =~ "Number"
    end

    test "renders validations", %{conn: conn, room_id: room_id} do
      {:ok, index_live, _html} = live(conn, ~p"/#{room_id}")

      assert index_live
             |> form("#user-form", user: %{name: nil, number: "9"})
             |> render_change() =~ "can&#39;t be blank"

      refute index_live
             |> form("#user-form", user: @create_attrs)
             |> render_change() =~ "can&#39;t be blank"
    end

    test "lists the users", %{conn: conn, room_id: room_id} do
      {:ok, index_live, _html} = live(conn, ~p"/#{room_id}")

      users = [
        %User{
          name: "Bob",
          number: 440,
          only_viewing: false
        },
        %User{
          name: "De Wet",
          number: 420,
          only_viewing: false
        },
        %User{
          name: "Marysol",
          number: nil,
          only_viewing: true
        }
      ]

      display_state =
        users
        |> Factory.input_state_for()
        |> DisplayState.from_input_state()

      send(index_live.pid, display_state)
      rendered = render(index_live)

      assert rendered =~ "Bob"
      assert rendered =~ "440"
      assert rendered =~ "De Wet"
      assert rendered =~ "420"
      assert rendered =~ "430"
      assert rendered =~ "Marysol"
      assert rendered =~ "Viewing 📺"
    end
  end

  test "shows and clears a flash of who cleared the numbers", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/9")

    send(view.pid, {:clear_number, "De Wet 🔥"})

    assert render(view) =~ "Numbers cleared by De Wet 🔥"

    refute view
           |> form("#user-form", user: @create_attrs)
           |> render_change() =~ "Numbers cleared by De Wet 🔥"
  end
end
