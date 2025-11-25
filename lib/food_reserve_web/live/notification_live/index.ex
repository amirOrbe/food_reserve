defmodule FoodReserveWeb.NotificationLive.Index do
  use FoodReserveWeb, :live_view

  alias FoodReserve.Notifications

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <!-- Header -->
        <div class="bg-white shadow-sm rounded-lg border border-gray-200 mb-6">
          <div class="px-6 py-8 sm:px-8">
            <div class="flex items-center justify-between mb-4">
              <div>
                <h1 class="text-3xl font-bold text-gray-900 mb-2">
                  Notificaciones
                </h1>
                <p class="text-gray-600">
                  Mantente al día con las actualizaciones de tus reservas
                </p>
              </div>

              <%= if @unread_count > 0 do %>
                <button
                  phx-click="mark_all_as_read"
                  class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-lg text-white bg-blue-600 hover:bg-blue-700"
                >
                  <.icon name="hero-check" class="w-4 h-4 mr-2" /> Marcar todas como leídas
                </button>
              <% end %>
            </div>

            <div class="flex gap-3">
              <.link
                navigate={~p"/"}
                class="inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-lg text-gray-700 bg-white hover:bg-gray-50"
              >
                <.icon name="hero-arrow-left" class="w-4 h-4 mr-2" /> Volver al Inicio
              </.link>
            </div>
          </div>
        </div>
        
    <!-- Lista de Notificaciones -->
        <div class="bg-white shadow-sm rounded-lg border border-gray-200">
          <div class="px-6 py-8 sm:px-8">
            <%= if length(@notifications) > 0 do %>
              <div class="space-y-4">
                <%= for notification <- @notifications do %>
                  <div class={[
                    "flex items-start p-4 rounded-lg border transition-colors duration-200",
                    if(notification.read,
                      do: "border-gray-200 bg-gray-50",
                      else: "border-blue-200 bg-blue-50"
                    )
                  ]}>
                    <div class={[
                      "flex-shrink-0 w-10 h-10 rounded-full flex items-center justify-center mr-4",
                      get_notification_bg_color(notification.type)
                    ]}>
                      <.icon
                        name={get_notification_icon(notification.type)}
                        class={
                          Enum.join(
                            [
                              "w-5 h-5",
                              get_notification_text_color(notification.type)
                            ],
                            " "
                          )
                        }
                      />
                    </div>

                    <div class="flex-1 min-w-0">
                      <div class="flex items-center justify-between mb-1">
                        <h3 class={[
                          "text-sm font-medium",
                          if(notification.read, do: "text-gray-900", else: "text-blue-900")
                        ]}>
                          {notification.title}
                        </h3>
                        <div class="flex items-center gap-2">
                          <span class="text-xs text-gray-500">
                            {format_notification_date(notification.inserted_at)}
                          </span>
                          <%= if not notification.read do %>
                            <button
                              phx-click="mark_as_read"
                              phx-value-id={notification.id}
                              class="text-xs text-blue-600 hover:text-blue-800"
                            >
                              Marcar como leída
                            </button>
                          <% end %>
                        </div>
                      </div>

                      <p class={[
                        "text-sm leading-relaxed",
                        if(notification.read, do: "text-gray-600", else: "text-blue-800")
                      ]}>
                        {notification.message}
                      </p>

                      <%= if notification.restaurant do %>
                        <div class="mt-2">
                          <.link
                            navigate={~p"/restaurants/#{notification.restaurant}"}
                            class="inline-flex items-center text-xs text-orange-600 hover:text-orange-800"
                          >
                            <.icon name="hero-building-storefront" class="w-3 h-3 mr-1" />
                            Ver restaurante
                          </.link>
                        </div>
                      <% end %>

                      <%= if notification.type == "review_reminder" and notification.restaurant do %>
                        <div class="mt-2">
                          <.link
                            navigate={~p"/restaurants/#{notification.restaurant}/review"}
                            class="inline-flex items-center text-xs text-yellow-600 hover:text-yellow-800"
                          >
                            <.icon name="hero-star" class="w-3 h-3 mr-1" /> Dejar reseña
                          </.link>
                        </div>
                      <% end %>
                    </div>
                  </div>
                <% end %>
              </div>
            <% else %>
              <div class="text-center py-12">
                <.icon name="hero-bell-slash" class="w-12 h-12 text-gray-300 mx-auto mb-4" />
                <h3 class="text-lg font-medium text-gray-900 mb-2">No tienes notificaciones</h3>
                <p class="text-gray-600">
                  Cuando tengas actualizaciones sobre tus reservas, aparecerán aquí.
                </p>
              </div>
            <% end %>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    notifications = Notifications.list_user_notifications(socket.assigns.current_scope)
    unread_count = Notifications.count_unread_notifications(socket.assigns.current_scope)

    {:ok,
     socket
     |> assign(:page_title, "Notificaciones")
     |> assign(:notifications, notifications)
     |> assign(:unread_count, unread_count)}
  end

  @impl true
  def handle_event("mark_as_read", %{"id" => id}, socket) do
    case Notifications.mark_as_read(socket.assigns.current_scope, String.to_integer(id)) do
      {:ok, _notification} ->
        # Recargar notificaciones
        notifications = Notifications.list_user_notifications(socket.assigns.current_scope)
        unread_count = Notifications.count_unread_notifications(socket.assigns.current_scope)

        {:noreply,
         socket
         |> assign(:notifications, notifications)
         |> assign(:unread_count, unread_count)
         |> put_flash(:info, "Notificación marcada como leída")}

      {:error, :not_found} ->
        {:noreply, put_flash(socket, :error, "Notificación no encontrada")}
    end
  end

  @impl true
  def handle_event("mark_all_as_read", _params, socket) do
    {count, _} = Notifications.mark_all_as_read(socket.assigns.current_scope)

    # Recargar notificaciones
    notifications = Notifications.list_user_notifications(socket.assigns.current_scope)
    unread_count = Notifications.count_unread_notifications(socket.assigns.current_scope)

    {:noreply,
     socket
     |> assign(:notifications, notifications)
     |> assign(:unread_count, unread_count)
     |> put_flash(:info, "#{count} notificaciones marcadas como leídas")}
  end

  # Helper functions

  defp get_notification_icon(type) do
    case type do
      "reservation_created" -> "hero-calendar-days"
      "reservation_confirmed" -> "hero-check-circle"
      "reservation_declined" -> "hero-x-circle"
      "review_reminder" -> "hero-star"
      "general" -> "hero-bell"
      _ -> "hero-bell"
    end
  end

  defp get_notification_bg_color(type) do
    case type do
      "reservation_created" -> "bg-blue-100"
      "reservation_confirmed" -> "bg-green-100"
      "reservation_declined" -> "bg-red-100"
      "review_reminder" -> "bg-yellow-100"
      "general" -> "bg-gray-100"
      _ -> "bg-gray-100"
    end
  end

  defp get_notification_text_color(type) do
    case type do
      "reservation_created" -> "text-blue-600"
      "reservation_confirmed" -> "text-green-600"
      "reservation_declined" -> "text-red-600"
      "review_reminder" -> "text-yellow-600"
      "general" -> "text-gray-600"
      _ -> "text-gray-600"
    end
  end

  defp format_notification_date(datetime) do
    now = DateTime.utc_now()
    diff = DateTime.diff(now, datetime, :second)

    cond do
      diff < 60 -> "Hace un momento"
      diff < 3600 -> "Hace #{div(diff, 60)} minutos"
      diff < 86400 -> "Hace #{div(diff, 3600)} horas"
      diff < 604_800 -> "Hace #{div(diff, 86400)} días"
      true -> Calendar.strftime(datetime, "%d/%m/%Y")
    end
  end
end
