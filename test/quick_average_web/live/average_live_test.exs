defmodule QuickAverageWeb.AverageLiveTest do
  use QuickAverageWeb.ConnCase
  alias Support.Factory

  alias QuickAverage.{
    DisplayState,
    User
  }

  import Phoenix.LiveViewTest

  @create_attrs %{name: "some name", number: 42}

  describe "Index" do
    test "renders the form", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/5")

      assert html =~ "Name"
      assert html =~ "Number"
    end

    test "renders validations", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/7")

      assert index_live
             |> form("#user-form", user: %{name: nil, number: "9"})
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#user-form", user: %{name: "De Wet", number: nil})
             |> render_change() =~ "can&#39;t be blank"

      refute index_live
             |> form("#user-form", user: @create_attrs)
             |> render_change() =~ "can&#39;t be blank"
    end

    test "lists the users", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/9")

      users = [
        %User{
          name: "Bob",
          number: 440
        },
        %User{
          name: "De Wet",
          number: 420
        }
      ]

      display_state =
        users
        |> Factory.presences_for()
        |> DisplayState.from_presences()

      send(index_live.pid, display_state)
      assert render(index_live) =~ "Bob"
      assert render(index_live) =~ "440"
      assert render(index_live) =~ "De Wet"
      assert render(index_live) =~ "420"
      assert render(index_live) =~ "430"
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
