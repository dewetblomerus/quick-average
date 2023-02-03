defmodule QuickAverageWeb.AverageLive do
  alias QuickAverage.Accounts.User
  alias QuickAverageWeb.Presence
  use QuickAverageWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.simple_form :let={f} for={@changeset} id="user-form" phx-change="update" phx-submit="save">
      <.input field={{f, :name}} type="text" label="Name" />
      <.input field={{f, :number}} type="number" label="Number" />
    </.simple_form>
    """
  end

  @impl true
  def mount(%{"room_id" => room_id}, _session, socket) do
    user = %User{}
    changeset = User.changeset(user, %{})

    Presence.track(
      self(),
      room_id,
      socket.id,
      %{"name" => "", "number" => nil}
    )

    {:ok,
     assign(socket, %{
       changeset: changeset,
       user: user,
       room_id: room_id
     })}
  end

  @impl true
  def handle_event("update", %{"user" => user_params}, socket) do
    changeset =
      socket.assigns.user
      |> User.changeset(user_params)
      |> Map.put(:action, :validate)

    Presence.update(
      self(),
      socket.assigns.room_id,
      socket.id,
      user_params
    )

    {:noreply, assign(socket, :changeset, changeset)}
  end
end
