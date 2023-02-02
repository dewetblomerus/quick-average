defmodule QuickAverageWeb.AverageLive do
  alias QuickAverage.Accounts.User
  use QuickAverageWeb, :live_view

  def render(assigns) do
    ~H"""
    <.simple_form :let={f} for={@changeset} id="user-form" phx-change="update" phx-submit="save">
      <.input field={{f, :name}} type="text" label="Name" />
      <.input field={{f, :number}} type="number" label="Number" />
    </.simple_form>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    user = %User{}
    changeset = User.changeset(user, %{})
    {:ok, assign(socket, %{changeset: changeset, user: user})}
  end

  @impl true
  def handle_event("update", %{"user" => user_params}, socket) do
    changeset =
      socket.assigns.user
      |> User.changeset(user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end
end
