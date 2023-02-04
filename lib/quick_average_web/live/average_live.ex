defmodule QuickAverageWeb.AverageLive do
  alias QuickAverage.Users
  alias QuickAverage.Accounts.User
  alias Phoenix.PubSub
  alias QuickAverageWeb.Presence
  use QuickAverageWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.simple_form :let={f} for={@changeset} id="user-form" phx-change="update" phx-submit="save">
      <.input field={{f, :name}} type="text" label="Name" />
      <.input field={{f, :number}} type="number" label="Number" />
    </.simple_form>
    <%= for user <- @users do %>
      <br />
      <%= user.name %>
      <%= user.number %>
    <% end %>
    """
  end

  @impl true
  def mount(%{"room_id" => room_id}, _session, socket) do
    user = %User{}
    changeset = User.changeset(user, %{})
    presence_track(room_id, socket)
    subscribe(room_id)

    {:ok,
     assign(socket, %{
       changeset: changeset,
       user: user,
       room_id: room_id,
       users: users(room_id)
     })}
  end

  @impl true
  def handle_event("update", %{"user" => user_params}, socket) do
    changeset =
      socket.assigns.user
      |> User.changeset(user_params)
      |> Map.put(:action, :validate)

    presence_update(socket, user_params)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  @impl true
  def handle_info(%{users: users}, socket) do
    {:noreply, assign(socket, %{users: users})}
  end

  def presence_track(room_id, socket) do
    Presence.track(
      self(),
      room_id,
      socket.id,
      %{"name" => "", "number" => nil}
    )
  end

  def presence_update(socket, user_params) do
    Presence.update(
      self(),
      socket.assigns.room_id,
      socket.id,
      user_params
    )
  end

  def users(room_id) do
    room_id
    |> Presence.list()
    |> Users.from_presences()
  end

  def subscribe(room_id) do
    PubSub.subscribe(QuickAverage.PubSub, Presence.display_topic(room_id))
  end
end
