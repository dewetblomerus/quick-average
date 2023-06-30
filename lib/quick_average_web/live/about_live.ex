defmodule QuickAverageWeb.AboutLive do
  use QuickAverageWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    # {:ok,
    #  assign(socket, root_url: QuickAverageWeb.Router.Helpers.url(socket.conn))}

    {:ok, socket}
  end
end
