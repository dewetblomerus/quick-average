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
    send(self(), :ask_frontend_to_restore_user)

    new_socket =
      assign(socket, %{
        average: "Waiting",
        changeset: User.changeset(%{}),
        flash_timer: nil,
        is_admin: false,
        is_revealed_manually: false,
        name: "",
        number: nil,
        only_viewing: false,
        room_id: room_id,
        users: []
      })

    PresenceInterface.track(new_socket)

    {:ok, new_socket}
  end

  @impl true
  def handle_params(_params, room_url, socket) do
    {:noreply, assign(socket, room_url: room_url)}
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
  def handle_event("text_copied", %{"text" => room_url}, socket) do
    {:noreply,
     put_timed_flash(
       socket,
       :info,
       "Room URL Copied to clipboard: #{room_url}"
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

    sanitized_user_params =
      Map.update!(user_params, "name", &String.slice(&1, 0, 20))

    should_update?(socket, changeset, sanitized_user_params) &&
      PresenceInterface.update(socket, sanitized_user_params)

    name =
      sanitized_user_params["name"]

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
       name: name,
       only_viewing: only_viewing
     })}
  end

  @impl true
  def handle_event("clear_clicked", _params, %{assigns: assigns} = socket) do
    PubSubInterface.broadcast(
      assigns.room_id,
      {:clear_number, assigns.name}
    )

    RoomManager.set_reveal(assigns.room_id, false)

    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "reveal_manually",
        params,
        %{assigns: assigns} = socket
      ) do
    is_revealed = params["value"] == "true"

    RoomManager.set_reveal(assigns.room_id, is_revealed)

    verb =
      if is_revealed do
        "revealed"
      else
        "hidden"
      end

    RoomManager.send_flash(
      assigns.room_id,
      :info,
      "Numbers #{verb} by #{assigns.name}"
    )

    {:noreply, socket}
  end

  @impl true
  def handle_info(:ask_frontend_to_restore_user, socket) do
    {:noreply, push_event(socket, "restore_user", %{})}
  end

  @impl true
  def handle_info(%DisplayState{users: users, average: average}, socket) do
    is_admin = socket.assigns.is_admin || alone?(users)

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
  def handle_info({:clear_number, clearer_name}, %{assigns: assigns} = socket) do
    user_params = %{
      "name" => assigns.name,
      "number" => nil,
      "only_viewing" => assigns.only_viewing
    }

    changeset = User.changeset(user_params)
    PresenceInterface.update(socket, user_params)

    new_socket =
      assign(socket, changeset: changeset, number: nil)
      |> put_timed_flash(:info, "Numbers cleared by #{clearer_name}")

    {:noreply, push_event(new_socket, "clear_number", %{})}
  end

  @impl true
  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end

  @impl true
  def handle_info({:show_flash, level, message}, socket) do
    {:noreply, put_flash(socket, level, message)}
  end

  @impl true
  def handle_info({:set_reveal, is_revealed_manually}, socket) do
    new_socket =
      assign(socket, is_revealed_manually: is_revealed_manually)

    {:noreply, new_socket}
  end

  defp alone?(users), do: length(users) < 2

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

  defp put_timed_flash(socket, key, message, timeout \\ 5000) do
    if socket.assigns.flash_timer do
      Process.cancel_timer(socket.assigns.flash_timer)
    end

    timer = Process.send_after(self(), :clear_flash, timeout)

    socket
    |> put_flash(key, message)
    |> assign(flash_timer: timer)
  end

  def parse_bool("false"), do: false
  def parse_bool("true"), do: true
  def parse_bool(input), do: !!input
  def reveal_text(true), do: "Hide"
  def reveal_text(false), do: "Reveal"
end
