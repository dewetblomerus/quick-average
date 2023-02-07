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
    <div id="hooker" phx-hook="RestoreUser"></div>
    <.simple_form
      :let={f}
      for={@changeset}
      id="user-form"
      phx-change="form_update"
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
    changeset = User.changeset(%User{}, %{})
    presence_track(room_id, socket)
    subscribe(room_id)

    {:ok,
     assign(socket, %{
       average: "Waiting",
       changeset: changeset,
       name: "",
       room_id: room_id,
       users: list_users(room_id)
     })}
  end

  @impl true
  def handle_event("restore_user", %{"name" => name} = partial_params, socket) do
    user_params = Map.put(partial_params, "number", nil)

    changeset = User.changeset(%User{}, user_params)

    presence_update(socket, user_params)

    new_socket =
      assign(
        socket,
        name: name,
        changeset: changeset
      )

    {:noreply, new_socket}
  end

  @impl true
  def handle_event(
        "form_update",
        %{"user" => %{"name" => name} = user_params},
        socket
      ) do
    changeset =
      %User{}
      |> User.changeset(user_params)
      |> Map.put(:action, :validate)

    presence_update(socket, user_params)

    new_socket =
      assign(
        socket,
        changeset: changeset,
        name: name
      )

    {:noreply, push_event(new_socket, "set_storage", %{name: name})}
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
    user_params = %{"name" => socket.assigns.name, "number" => nil}

    changeset = User.changeset(%User{}, user_params)

    presence_update(socket, user_params)

    new_socket = assign(socket, changeset: changeset)

    {:noreply, push_event(new_socket, "clear_number", %{})}
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
