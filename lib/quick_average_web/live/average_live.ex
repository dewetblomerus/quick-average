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

  import QuickAverageWeb.UserListItem

  @impl true
  def mount(%{"room_id" => room_id}, _session, socket) do
    ManagerSupervisor.create(room_id)
    PubSubInterface.subscribe_display(room_id)

    new_socket =
      assign(socket, %{
        average: "Waiting",
        changeset: User.changeset(%{}),
        is_admin: false,
        manual_reveal?: false,
        name: "",
        number: nil,
        only_viewing: false,
        room_id: room_id,
        users: []
      })

    PresenceInterface.track(new_socket)

    {
      :ok,
      new_socket
    }
  end

  @impl true
  def handle_event(
        "restore_user",
        %{
          "name" => name,
          "admin_token" => admin_token,
          "only_viewing" => only_viewing_input
        } = partial_params,
        socket
      ) do
    only_viewing = parse_bool(only_viewing_input)

    is_admin =
      socket.assigns.is_admin ||
        validate_admin_token(socket.assigns.room_id, admin_token)

    user_params = Map.put(partial_params, "number", nil)
    PresenceInterface.update(socket, user_params)

    {:noreply,
     assign(
       socket,
       changeset: User.changeset(user_params),
       is_admin: is_admin,
       name: name,
       only_viewing: only_viewing
     )}
  end

  @impl true
  def handle_event(
        "form_update",
        %{
          "user" => user_params
        },
        socket
      ) do
    changeset =
      user_params
      |> User.changeset()
      |> Map.put(:action, :validate)

    should_update?(socket, changeset, user_params) &&
      PresenceInterface.update(socket, user_params)

    name = user_params["name"]
    only_viewing = parse_bool(user_params["only_viewing"])

    new_socket =
      assign(
        socket,
        changeset: changeset,
        name: name,
        number: user_params["number"],
        only_viewing: only_viewing
      )
      |> clear_flash()

    {:noreply,
     push_event(new_socket, "set_storage", %{
       name: String.slice(name, 0, 25),
       only_viewing: only_viewing
     })}
  end

  @impl true
  def handle_event("clear_clicked", _params, socket) do
    PubSubInterface.broadcast(
      socket.assigns.room_id,
      {:clear_number, socket.assigns.name}
    )

    RoomManager.set_reveal(socket.assigns.room_id, false)

    {:noreply, socket}
  end

  @impl true
  def handle_event("reveal_clicked", _params, socket) do
    RoomManager.toggle_reveal(socket.assigns.room_id, socket.assigns.name)

    {:noreply, socket}
  end

  @impl true
  def handle_info(%DisplayState{users: users, average: average}, socket) do
    is_admin = socket.assigns.is_admin || is_alone?(users)

    if is_admin do
      send(self(), :persist_admin)
    end

    {:noreply,
     assign(socket, %{users: users, average: average, is_admin: is_admin})}
  end

  @impl true
  def handle_info(:persist_admin, socket) do
    {:noreply,
     push_event(
       socket,
       "set_storage",
       %{admin_token: generate_admin_token(socket.assigns.room_id)}
     )}
  end

  @impl true
  def handle_info({:clear_number, clearer_name}, socket) do
    user_params = %{
      "name" => socket.assigns.name,
      "number" => nil,
      "only_viewing" => socket.assigns.only_viewing
    }

    changeset = User.changeset(user_params)
    PresenceInterface.update(socket, user_params)

    new_socket =
      assign(socket, changeset: changeset, number: nil)
      |> put_flash(:info, "Numbers cleared by #{clearer_name}")

    Process.send_after(self(), :clear_flash, 5000)

    {:noreply, push_event(new_socket, "clear_number", %{})}
  end

  @impl true
  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end

  @impl true
  def handle_info({:set_reveal, name, manual_reveal?}, socket) do
    verb =
      if manual_reveal? do
        "revealed"
      else
        "hidden"
      end

    new_socket =
      assign(socket, manual_reveal?: manual_reveal?)
      |> put_flash(:info, "Numbers #{verb}ed by #{name}")

    {:noreply, new_socket}
  end

  defp is_alone?(users), do: length(users) < 2

  defp generate_admin_token(room_id) do
    Phoenix.Token.sign(
      QuickAverageWeb.Endpoint,
      "admin state",
      "#{room_id}:true"
    )
  end

  defp validate_admin_token(room_id, token) do
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

  defp should_update?(socket, changeset, user_params) do
    [:name, :number, :only_viewing]
    |> Enum.any?(fn field ->
      valid_field_change?(field, socket, changeset, user_params)
    end)
  end

  defp valid_field_change?(field, socket, changeset, user_params) do
    string_field = Atom.to_string(field)

    socket.assigns[field] != user_params[string_field] &&
      !Keyword.has_key?(changeset.errors, field)
  end

  def parse_bool("false"), do: false
  def parse_bool("true"), do: true
  def parse_bool(input), do: !!input
  def reveal_text(true), do: "Hide"
  def reveal_text(false), do: "Reveal"
end
