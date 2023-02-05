defmodule QuickAverageWeb.AverageLiveTest do
  use QuickAverageWeb.ConnCase
  alias QuickAverage.DisplayState

  import Phoenix.LiveViewTest

  @create_attrs %{name: "some name", number: 42}

  describe "Index" do
    test "renders the form", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/5")

      assert html =~ "Name"
      assert html =~ "Number"
    end

    test "renders validations", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/5")

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
        %{
          name: "Bob",
          number: "440"
        },
        %{
          name: "De Wet",
          number: "420"
        }
      ]

      display_state = DisplayState.from_users(users)
      send(index_live.pid, display_state)
      assert render(index_live) =~ "Bob"
      assert render(index_live) =~ "440"
      assert render(index_live) =~ "De Wet"
      assert render(index_live) =~ "420"
      assert render(index_live) =~ "430"
    end
  end
end
