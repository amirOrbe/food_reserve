defmodule FoodReserve.ReviewScheduler do
  @moduledoc """
  Scheduler for processing review reminders in the background.

  Note: In a real environment, we would use a library like Quantum or Oban
  for scheduling background tasks. This is a fictional implementation
  for demonstration purposes.
  """

  use GenServer
  require Logger

  # Interval for processing reminders (hourly in this example)
  # 1 hour in milliseconds
  @check_interval 60 * 60 * 1000

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    # Schedule the first check
    schedule_next_check()
    {:ok, state}
  end

  @impl true
  def handle_info(:process_reminders, state) do
    Logger.info("Processing review reminders...")

    # Process completed reservations and send reminders
    FoodReserve.ReviewReminders.process_completed_reservations()

    # Schedule the next check
    schedule_next_check()
    {:noreply, state}
  end

  defp schedule_next_check do
    Process.send_after(self(), :process_reminders, @check_interval)
  end
end
