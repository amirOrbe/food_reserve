defmodule FoodReserveWeb.LiveHelpers do
  @moduledoc """
  Helper functions for LiveViews, including real-time notifications.
  """

  import Phoenix.Component, only: [assign: 3]
  alias FoodReserve.Notifications

  @doc """
  Handles real-time notification events and updates the unread count.
  Call this from handle_info/2 in your LiveViews.
  """
  def handle_notification_event({:new_notification, _notification}, socket) do
    # Recalculate unread notifications count
    new_count =
      if socket.assigns.current_scope && socket.assigns.current_scope.user do
        Notifications.count_unread_notifications(socket.assigns.current_scope)
      else
        0
      end

    {:noreply, assign(socket, :unread_notifications_count, new_count)}
  end

  @doc """
  Macro to easily add notification handling to LiveViews.
  """
  defmacro handle_notifications do
    quote do
      @impl true
      def handle_info({:new_notification, _notification} = event, socket) do
        FoodReserveWeb.LiveHelpers.handle_notification_event(event, socket)
      end
    end
  end

  @doc """
  Handles the toggle_mobile_menu event for the mobile navigation.
  """
  def handle_toggle_mobile_menu(socket) do
    current_state = Map.get(socket.assigns, :mobile_menu_open, false)
    {:noreply, assign(socket, :mobile_menu_open, !current_state)}
  end

  @doc """
  Macro to add mobile menu handling to LiveViews.
  """
  defmacro handle_mobile_menu do
    quote do
      @impl true
      def handle_event("toggle_mobile_menu", _params, socket) do
        FoodReserveWeb.LiveHelpers.handle_toggle_mobile_menu(socket)
      end
    end
  end
end
