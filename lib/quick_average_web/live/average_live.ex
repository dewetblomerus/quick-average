defmodule QuickAverageWeb.AverageLive do
  use QuickAverageWeb, :live_view

  alias QuickAverage.Presence.Interface, as: PresenceInterface

  alias QuickAverage.{
    DisplayState,
    User
  }

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

    <%= if @is_admin do %>
      <.button phx-click="clear_clicked">Clear Numbers</.button>
    <% end %>

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
    PresenceInterface.subscribe_display(room_id)
    %{users: users, average: average} = PresenceInterface.list_users(room_id)
    is_admin = length(users) < 2

    new_socket =
      assign(socket, %{
        average: average,
        changeset: User.changeset(%{}),
        is_admin: is_admin,
        name: "",
        room_id: room_id,
        users: users
      })

    PresenceInterface.track(new_socket)

    {
      :ok,
      set_admin_token(new_socket, is_admin)
    }
  end

  def set_admin_token(socket, true) do
    push_event(
      socket,
      "set_storage",
      %{admin_token: generate_admin_token(socket.assigns.room_id)}
    )
  end

  def set_admin_token(socket, false), do: socket

  @impl true
  def handle_event(
        "restore_user",
        %{"name" => name, "admin_token" => admin_token} = partial_params,
        socket
      ) do
    is_admin =
      socket.assigns.is_admin ||
        validate_admin_token(socket.assigns.room_id, admin_token)

    user_params = Map.put(partial_params, "number", nil)
    PresenceInterface.update(socket, user_params)

    {:noreply,
     assign(
       socket,
       is_admin: is_admin,
       name: name,
       changeset: User.changeset(user_params)
     )}
  end

  @impl true
  def handle_event(
        "form_update",
        %{"user" => %{"name" => name} = user_params},
        socket
      ) do
    PresenceInterface.update(socket, user_params)

    changeset =
      user_params
      |> User.changeset()
      |> Map.put(:action, :validate)

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
    PresenceInterface.broadcast(socket.assigns.room_id, :clear_number)
    {:noreply, socket}
  end

  @impl true
  def handle_info(%DisplayState{users: users, average: average}, socket) do
    {:noreply, assign(socket, %{users: users, average: average})}
  end

  @impl true
  def handle_info(:clear_number, socket) do
    user_params = %{"name" => socket.assigns.name, "number" => nil}
    changeset = User.changeset(user_params)
    PresenceInterface.update(socket, user_params)
    new_socket = assign(socket, changeset: changeset)

    {:noreply, push_event(new_socket, "clear_number", %{})}
  end

  def generate_admin_token(room_id) do
    Phoenix.Token.sign(
      QuickAverageWeb.Endpoint,
      "admin state",
      "#{room_id}:true"
    )
  end

  def validate_admin_token(room_id, token) do
    admin_string = "#{room_id}:true"

    admin_state =
      Phoenix.Token.verify(
        QuickAverageWeb.Endpoint,
        "admin state",
        token,
        max_age: 86_400
      )

    case admin_state do
      {:ok, ^admin_string} -> true
      _ -> false
    end
  end
end
