defmodule QuickAverageWeb.AverageLive do
  use QuickAverageWeb, :live_view

  alias Phoenix.PubSub

  alias QuickAverage.{
    DisplayState,
    User,
    Users
  }

  alias QuickAverageWeb.Presence

  @impl true
  def render(assigns) do
    ~H"""
    <.simple_form
      :let={f}
      for={@changeset}
      id="user-form"
      phx-change="update"
      phx-submit="save"
    >
      <.input field={{f, :name}} type="text" label="Name" />
      <.input field={{f, :number}} type="number" label="Number" />
    </.simple_form>

    <.button phx-click="clear_clicked">Clear Numbers</.button>

    <br />
    <h2>Average: <%= @average %></h2>
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
       average: "Waiting",
       changeset: changeset,
       user: user,
       room_id: room_id,
       users: list_users(room_id)
     })}
  end

  @impl true
  def handle_event("update", %{"user" => user_params}, socket) do
    user = User.from_params(user_params)

    changeset =
      user
      |> User.changeset(user_params)
      |> Map.put(:action, :validate)

    presence_update(socket, user_params)

    {:noreply,
     assign(
       socket,
       changeset: changeset,
       user: user
     )}
  end

  @impl true
  def handle_event("clear_clicked", _params, socket) do
    pubsub_broadcast(socket.assigns.room_id, :clear_number)
    {:noreply, socket}
  end

  @impl true
  def handle_info(%DisplayState{users: users, average: average}, socket) do
    {:noreply, assign(socket, %{users: users, average: average})}
  end

  @impl true
  def handle_info(:clear_number, socket) do
    user = %User{socket.assigns.user | number: nil}
    user_params = User.to_params(user)

    changeset =
      user
      |> User.changeset(Map.from_struct(user))

    presence_update(socket, user_params)

    {
      :noreply,
      push_event(
        assign(socket, user: user, changeset: changeset),
        "clear_number",
        %{}
      )
    }
  end

  def presence_track(room_id, socket) do
    Presence.track(
      self(),
      room_id,
      socket.id,
      %{"name" => "Anonymous", "number" => "waiting"}
    )
  end

  def presence_update(
        socket,
        %{"name" => _name, "number" => _number} = user_params
      ) do
    Presence.update(
      self(),
      socket.assigns.room_id,
      socket.id,
      user_params
    )
  end

  def pubsub_broadcast(room_id, event) do
    room_id
    |> Presence.display_topic()
    |> Presence.broadcast(event)
  end

  def list_users(room_id) do
    room_id
    |> Presence.list()
    |> Users.from_presences()
  end

  def subscribe(room_id) do
    PubSub.subscribe(QuickAverage.PubSub, Presence.display_topic(room_id))
  end
end
