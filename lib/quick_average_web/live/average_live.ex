defmodule QuickAverageWeb.AverageLive do
  use QuickAverageWeb, :live_view

  alias QuickAverage.Presence.Interface, as: PresenceInterface
  alias QuickAverage.PubSub.Interface, as: PubSubInterface

  alias QuickAverage.RoomManager.SupervisorInterface,
    as: ManagerSupervisor

  alias QuickAverage.{
    DisplayState,
    RoomManager,
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

      <.input
        field={{f, :number}}
        type="number"
        label="Number"
        disabled={parse_bool(@only_viewing)}
      />

      <.input field={{f, :only_viewing}} type="checkbox" label="Only Viewing" />
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
    ManagerSupervisor.create(room_id)
    PubSubInterface.subscribe_display(room_id)

    trackable_socket =
      assign(socket, %{
        room_id: room_id,
        changeset: User.changeset(%{}),
        name: "",
        only_viewing: false
      })

    PresenceInterface.track(trackable_socket)

    %{users: users, average: average} = RoomManager.get_display_state(room_id)
    is_admin = length(users) < 1

    new_socket =
      assign(trackable_socket, %{
        is_admin: is_admin,
        users: users,
        average: average
      })

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
        %{
          "user" =>
            %{"name" => name, "only_viewing" => only_viewing_input} =
              user_params
        },
        socket
      ) do
    PresenceInterface.update(socket, user_params)
    only_viewing = parse_bool(only_viewing_input)

    action =
      if only_viewing do
        nil
      else
        :validate
      end

    changeset =
      user_params
      |> User.changeset()
      |> Map.put(:action, action)

    new_socket =
      assign(
        socket,
        changeset: changeset,
        name: name,
        only_viewing: only_viewing
      )

    {:noreply, push_event(new_socket, "set_storage", %{name: name})}
  end

  @impl true
  def handle_event("clear_clicked", _params, socket) do
    PubSubInterface.broadcast(socket.assigns.room_id, :clear_number)
    {:noreply, socket}
  end

  @impl true
  def handle_info(%DisplayState{users: users, average: average}, socket) do
    {:noreply, assign(socket, %{users: users, average: average})}
  end

  @impl true
  def handle_info(:clear_number, socket) do
    user_params = %{
      "name" => socket.assigns.name,
      "number" => nil,
      "only_viewing" => socket.assigns.only_viewing
    }

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

  def parse_bool("false"), do: false
  def parse_bool("true"), do: true
  def parse_bool(input), do: !!input
end
