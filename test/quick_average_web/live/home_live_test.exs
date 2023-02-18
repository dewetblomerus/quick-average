defmodule QuickAverageWeb.HomeLiveTest do
  use QuickAverageWeb.ConnCase
  import Phoenix.LiveViewTest

  test "GET /", %{conn: conn} do
    {:error, {:redirect, %{to: "/" <> room_id}}} = live(conn, ~p"/")
    assert String.to_integer(room_id) > 0
  end
end
