defmodule QuickAverageWeb.BenchmarkLive do
  use QuickAverageWeb, :live_view
  alias QuickAverage.Benchmark
  alias QuickAverage.Benchmark.SupervisorInterface, as: BenchmarkSupervisor

  def render(assigns) do
    ~H"""
    <div class="pl-4 pt-4 pr-4">
      <.simple_form
        :let={f}
        for={@form}
        id="benchmark-form"
        phx-change="form_update"
      >
        <.input field={{f, :room_id}} type="text" label="Room ID" maxlength={40} />
        <.input
          field={{f, :amount}}
          type="text"
          label="Amount"
          max={1_000_000}
          min={0}
        />
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok,
     assign(
       socket,
       %{
         form: to_form(Benchmark.changeset(%{}))
       }
     )}
  end

  def handle_event(
        "form_update",
        %{"room_id" => room_id, "amount" => raw_amount} = params,
        socket
      ) do
    amount = sanitize_amount(raw_amount)
    BenchmarkSupervisor.implement(room_id, amount)

    {:noreply,
     assign(
       socket,
       %{
         form: to_form(Benchmark.changeset(params))
       }
     )}
  end

  defp sanitize_amount(""), do: 0
  defp sanitize_amount(raw_amount), do: String.to_integer(raw_amount)
end
