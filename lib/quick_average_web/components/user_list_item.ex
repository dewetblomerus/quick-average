defmodule QuickAverageWeb.UserListItem do
  use Phoenix.Component

  attr :name, :string, required: true
  attr :number, :string, required: true

  def display_user(assigns) do
    ~H"""
    <div class="flex flex-nowrap justify-between even:bg-gray-200 last:rounded-b-xl">
      <div class="pl-4"><%= @name %></div>
      <div class="text-right pr-4"><%= display_number(@number) %></div>
    </div>
    """
  end

  def display_number(:waiting), do: "Waiting ⏳"
  def display_number(:hidden), do: "Hidden ✅"
  def display_number(:viewing), do: "Viewing 📺"
  def display_number(number), do: number
end
