defmodule QuickAverageWeb.AverageLive do
  use QuickAverageWeb, :live_view

  alias QuickAverage.{
    DisplayState,
    User
  }

  alias QuickAverageWeb.PresenceInterface

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
    PresenceInterface.track(room_id, socket)
    PresenceInterface.subscribe_display(room_id)

    {:ok,
     assign(socket, %{
       average: "Waiting",
       changeset: User.changeset(%{}),
       name: "",
       room_id: room_id,
       users: PresenceInterface.list_users(room_id)
     })}
  end

  @impl true
  def handle_event("restore_user", %{"name" => name} = partial_params, socket) do
    user_params = Map.put(partial_params, "number", nil)
    PresenceInterface.update(socket, user_params)

    {:noreply,
     assign(
       socket,
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
end
