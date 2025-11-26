defmodule FoodReserveWeb.ReservationLive.Edit do
  use FoodReserveWeb, :live_view
  import FoodReserveWeb.LiveHelpers

  alias FoodReserve.Reservations
  alias FoodReserve.Restaurants

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app
      flash={@flash}
      current_scope={@current_scope}
      unread_notifications_count={@unread_notifications_count}
    >
      <div class="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div class="bg-white shadow-sm rounded-lg border border-gray-200 mb-6">
          <div class="px-6 py-8 sm:px-8">
            <div class="flex items-center justify-between">
              <div>
                <h1 class="text-3xl font-bold text-gray-900 mb-2">
                  Editar Reservación
                </h1>
                <p class="text-gray-600">
                  Actualiza los detalles de tu reservación para
                  <span class="font-medium">{@restaurant.name}</span>
                </p>
              </div>
              <.link
                navigate={~p"/my-reservations"}
                class="inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-lg text-gray-700 bg-white hover:bg-gray-50"
              >
                <.icon name="hero-arrow-left" class="w-4 h-4 mr-2" /> Volver a reservaciones
              </.link>
            </div>
          </div>
        </div>

        <div class="bg-white shadow-sm rounded-lg border border-gray-200">
          <div class="px-6 py-8 sm:px-8">
            <.form
              for={@form}
              id="reservation-form"
              phx-change="validate"
              phx-submit="save"
            >
              <div class="space-y-6">
                <!-- Date and Time Selection -->
                <div>
                  <h3 class="text-lg font-medium text-gray-900 mb-4">Fecha y Hora</h3>

                  <div class="grid grid-cols-1 sm:grid-cols-2 gap-6">
                    <div>
                      <.input
                        field={@form[:reservation_date]}
                        type="date"
                        label="Fecha"
                        min={Date.to_iso8601(Date.utc_today())}
                        value={@selected_date && Date.to_iso8601(@selected_date)}
                        phx-change="date_changed"
                      />
                    </div>

                    <div>
                      <div class="w-full">
                        <label class="block text-sm font-medium text-gray-700 mb-1">
                          Hora
                        </label>
                        <%= if @available_times != [] do %>
                          <div class="grid grid-cols-3 sm:grid-cols-4 gap-2 mt-1">
                            <%= for time <- @available_times do %>
                              <button
                                type="button"
                                phx-click="time_selected"
                                phx-value-time={time}
                                class={
                                  Enum.join(
                                    [
                                      "inline-flex justify-center py-2 px-4 border text-sm font-medium rounded-lg transition-colors",
                                      if(
                                        @selected_time &&
                                          Time.to_iso8601(@selected_time) == Time.to_iso8601(time),
                                        do: "bg-green-600 text-white",
                                        else: "border-gray-300 text-gray-700 hover:bg-gray-50"
                                      )
                                    ],
                                    " "
                                  )
                                }
                              >
                                {Time.to_string(time)
                                |> String.slice(0..4)}
                              </button>
                            <% end %>
                          </div>
                          <input
                            type="hidden"
                            name={@form[:reservation_time].name}
                            value={
                              if(@selected_time,
                                do: format_time_value(@selected_time),
                                else: format_time_value(@reservation.reservation_time)
                              )
                            }
                          />
                          <!-- Backup time value -->
                          <input
                            type="hidden"
                            name="reservation[_time_backup]"
                            value={format_time_value(@reservation.reservation_time)}
                          />
                        <% else %>
                          <div class="p-3 bg-gray-100 border border-gray-300 rounded-md text-sm text-gray-500">
                            <%= if @selected_date do %>
                              <div class="flex items-center">
                                <.icon
                                  name="hero-exclamation-triangle"
                                  class="w-4 h-4 mr-2 text-amber-500"
                                /> No hay horarios disponibles para esta fecha
                              </div>
                              <p class="mt-1 text-xs">
                                Todos los horarios están reservados o el restaurante está cerrado
                              </p>
                            <% else %>
                              <div class="flex items-center">
                                <.icon name="hero-calendar-days" class="w-4 h-4 mr-2 text-blue-500" />
                                Selecciona una fecha para ver horarios disponibles
                              </div>
                            <% end %>
                          </div>
                        <% end %>
                      </div>
                    </div>
                  </div>
                </div>
                
    <!-- Party Size -->
                <div>
                  <.input
                    field={@form[:party_size]}
                    type="number"
                    label="Número de personas"
                    min="1"
                    max="20"
                    placeholder="¿Cuántas personas?"
                    required
                    phx-change="party_size_changed"
                    phx-debounce="300"
                  />
                  <!-- Hidden input to ensure party_size is always submitted -->
                  <input
                    type="hidden"
                    name="reservation[_party_size_backup]"
                    value={@reservation.party_size}
                  />
                </div>
                
    <!-- Customer Information -->
                <div class="border-t border-gray-200 pt-6">
                  <h3 class="text-lg font-medium text-gray-900 mb-4">Información de Contacto</h3>

                  <div class="grid grid-cols-1 sm:grid-cols-2 gap-6">
                    <div>
                      <.input
                        field={@form[:customer_name]}
                        type="text"
                        label="Nombre completo"
                        placeholder="Tu nombre completo"
                        required
                      />
                    </div>

                    <div>
                      <.input
                        field={@form[:customer_phone]}
                        type="tel"
                        label="Teléfono"
                        placeholder="Tu número de teléfono"
                        required
                      />
                    </div>
                  </div>

                  <div class="mt-6">
                    <.input
                      field={@form[:customer_email]}
                      type="email"
                      label="Correo electrónico"
                      placeholder="tu@correo.com"
                      required
                    />
                  </div>
                </div>
                
    <!-- Special Requests -->
                <div>
                  <.input
                    field={@form[:special_requests]}
                    type="textarea"
                    label="Solicitudes especiales (opcional)"
                    placeholder="Alergias, preferencias de mesa, celebraciones especiales, etc."
                    rows="3"
                  />
                </div>
                
    <!-- Working Hours Info -->
                <%= if not Enum.empty?(@working_hours) do %>
                  <div class="bg-blue-50 border border-blue-200 rounded-lg p-4">
                    <h4 class="font-medium text-blue-900 mb-2">Horarios del Restaurante</h4>
                    <div class="grid grid-cols-2 gap-2 text-sm text-blue-800">
                      <%= for working_hour <- @working_hours do %>
                        <div class="flex justify-between">
                          <span>
                            {FoodReserve.Restaurants.WorkingHour.day_name(working_hour.day_of_week)}
                          </span>
                          <span>
                            <%= if working_hour.is_closed do %>
                              Cerrado
                            <% else %>
                              {Calendar.strftime(working_hour.open_time, "%H:%M")} - {Calendar.strftime(
                                working_hour.close_time,
                                "%H:%M"
                              )}
                            <% end %>
                          </span>
                        </div>
                      <% end %>
                    </div>
                  </div>
                <% end %>
                
    <!-- Submit Button -->
                <div class="flex justify-end gap-3 pt-6 border-t border-gray-200">
                  <.link
                    navigate={~p"/my-reservations"}
                    class="inline-flex justify-center items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-lg text-gray-700 bg-white hover:bg-gray-50"
                  >
                    Cancelar
                  </.link>
                  <button
                    type="button"
                    id="update-reservation-button"
                    phx-disable-with="Actualizando..."
                    class="inline-flex justify-center items-center px-6 py-2 border border-transparent text-sm font-medium rounded-lg text-white bg-blue-600 hover:bg-blue-700"
                    phx-click="manual_save"
                  >
                    <.icon name="hero-check" class="w-4 h-4 mr-2" /> Actualizar Reservación
                  </button>
                </div>
              </div>
            </.form>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    # Get the reservation with all necessary data
    reservation = Reservations.get_reservation!(socket.assigns.current_scope, id)
    restaurant = Restaurants.get_restaurant!(reservation.restaurant_id)

    # Check if the reservation belongs to the current user
    if reservation.user_id != socket.assigns.current_scope.user.id do
      {:ok,
       socket
       |> put_flash(:error, "You don't have permission to edit this reservation.")
       |> push_navigate(to: ~p"/my-reservations")}
    else
      # Get all necessary data
      working_hours = Restaurants.get_public_working_hours(restaurant.id)
      available_dates = Date.range(Date.utc_today(), Date.add(Date.utc_today(), 30))

      # Create the changeset
      changeset = Reservations.change_reservation(socket.assigns.current_scope, reservation)

      # Get available times for the selected date
      available_times =
        get_available_times_for_date(
          reservation.reservation_date,
          working_hours,
          restaurant.id,
          reservation.id
        )

      {:ok,
       socket
       |> assign(:page_title, "Edit Reservation")
       |> assign(:reservation, reservation)
       |> assign(:restaurant, restaurant)
       |> assign(:working_hours, working_hours)
       |> assign(:available_dates, available_dates)
       |> assign(:selected_date, reservation.reservation_date)
       |> assign(:available_times, available_times)
       |> assign(:selected_time, reservation.reservation_time)
       |> assign(:form, to_form(changeset))}
    end
  end

  @impl true
  def handle_event(
        "date_changed",
        %{"reservation" => %{"reservation_date" => date_string}},
        socket
      ) do
    case Date.from_iso8601(date_string) do
      {:ok, date} ->
        # Get available times for the selected date
        # Pass the reservation ID to exclude current reservation from conflicts
        available_times =
          get_available_times_for_date(
            date,
            socket.assigns.working_hours,
            socket.assigns.restaurant.id,
            socket.assigns.reservation.id
          )

        # Update form with new date
        changeset =
          socket.assigns.current_scope
          |> Reservations.change_reservation(socket.assigns.reservation, %{
            "reservation_date" => date
          })

        {:noreply,
         socket
         |> assign(:selected_date, date)
         |> assign(:available_times, available_times)
         |> assign(:selected_time, nil)
         |> assign(:form, to_form(changeset))}

      _ ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("time_selected", %{"time" => time_string}, socket) do
    case Time.from_iso8601(time_string) do
      {:ok, time} ->
        # Update form with new time
        changeset =
          socket.assigns.current_scope
          |> Reservations.change_reservation(socket.assigns.reservation, %{
            "reservation_time" => time
          })

        {:noreply,
         socket
         |> assign(:selected_time, time)
         |> assign(:form, to_form(changeset))}

      _ ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("manual_save", _params, socket) do
    IO.puts("MANUAL SAVE BUTTON CLICKED!")

    # Get form data from the socket's assigns
    reservation = socket.assigns.reservation

    # Get form data directly from the form in assigns
    changeset = socket.assigns.form.source

    # Get updated values from the changeset or from the form params
    params = changeset.params || %{}

    # Start with all essential fields from current reservation
    essential_params = %{
      "id" => reservation.id,
      "reservation_date" => reservation.reservation_date,
      "reservation_time" => reservation.reservation_time,
      "customer_name" => reservation.customer_name,
      "customer_phone" => reservation.customer_phone,
      "customer_email" => reservation.customer_email,
      "special_requests" => reservation.special_requests || ""
    }

    # Merge with form params, with form params taking precedence
    params = Map.merge(essential_params, params)

    # Always include party_size in a type-safe way
    party_size =
      case Map.get(params, "party_size") do
        nil -> reservation.party_size
        "" -> reservation.party_size
        ps when is_binary(ps) -> String.to_integer(ps)
        ps when is_integer(ps) -> ps
        _ -> reservation.party_size
      end

    # Ensure reservation_time is a string (if needed)
    reservation_time =
      case params["reservation_time"] do
        time when is_binary(time) -> time
        %Time{} = time -> Time.to_iso8601(time)
        _ -> Time.to_iso8601(reservation.reservation_time)
      end

    # Ensure reservation_date is a string (if needed)
    reservation_date =
      case params["reservation_date"] do
        date when is_binary(date) -> date
        %Date{} = date -> Date.to_iso8601(date)
        _ -> Date.to_iso8601(reservation.reservation_date)
      end

    # Update final params
    params =
      params
      |> Map.put("party_size", party_size)
      |> Map.put("reservation_time", reservation_time)
      |> Map.put("reservation_date", reservation_date)

    IO.puts("Final parameters for update: #{inspect(params)}")

    # Process the update
    result = Reservations.update_reservation(socket.assigns.current_scope, reservation, params)
    IO.puts("Update result: #{inspect(result)}")

    case result do
      {:ok, updated} ->
        IO.puts("Reservation updated successfully! New party_size: #{updated.party_size}")

        {:noreply,
         socket
         |> put_flash(:info, "Reservation updated successfully!")
         |> push_navigate(to: ~p"/my-reservations")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  @impl true
  def handle_event("party_size_changed", %{"reservation" => params}, socket) do
    params =
      if Map.has_key?(params, "party_size") and params["party_size"] != "" do
        Map.update(params, "party_size", nil, &parse_party_size/1)
      else
        params
      end

    changeset =
      socket.assigns.current_scope
      |> Reservations.change_reservation(socket.assigns.reservation, params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  @impl true
  def handle_event("validate", %{"reservation" => params}, socket) do
    params =
      if Map.has_key?(params, "party_size") and params["party_size"] != "" do
        Map.update(params, "party_size", nil, &parse_party_size/1)
      else
        params
      end

    changeset =
      socket.assigns.current_scope
      |> Reservations.change_reservation(socket.assigns.reservation, params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  @impl true
  def handle_event("save", %{"reservation" => params}, socket) do
    # Add debug logging for troubleshooting
    IO.puts("Save event received with params: #{inspect(params)}")
    IO.puts("BUTTON CLICKED - SAVING RESERVATION!")

    # Just proceed with normal LiveView event handling

    # Always include essential fields and ensure proper types
    params =
      params
      |> Map.put("id", socket.assigns.reservation.id)

    # Explicitly add party_size field, parsing it if it exists or using current value
    party_size =
      case Map.get(params, "party_size") do
        nil -> socket.assigns.reservation.party_size
        "" -> socket.assigns.reservation.party_size
        ps when is_binary(ps) -> String.to_integer(ps)
        ps when is_integer(ps) -> ps
        _ -> socket.assigns.reservation.party_size
      end

    # Ensure party_size is in the params
    params = Map.put(params, "party_size", party_size)

    # Ensure reservation_date and reservation_time are included
    params =
      params
      |> ensure_param("reservation_date", socket.assigns.reservation.reservation_date)

    # Process reservation_time with special care - always ensure it's a string
    time_string =
      case Map.get(params, "reservation_time") do
        nil ->
          # Try to get from backup field
          backup_time = Map.get(params, "_time_backup")

          if backup_time && backup_time != "",
            do: backup_time,
            else: format_time_value(socket.assigns.reservation.reservation_time)

        "" ->
          format_time_value(socket.assigns.reservation.reservation_time)

        value when is_binary(value) ->
          value

        _ ->
          format_time_value(socket.assigns.reservation.reservation_time)
      end

    # Ensure reservation_time is properly set
    params = Map.put(params, "reservation_time", time_string)

    # Make sure selected_time is set to maintain consistency
    socket =
      assign(
        socket,
        :selected_time,
        parse_time_value(
          Map.get(params, "reservation_time", socket.assigns.reservation.reservation_time)
        )
      )

    case Reservations.update_reservation(
           socket.assigns.current_scope,
           socket.assigns.reservation,
           params
         ) do
      {:ok, _reservation} ->
        {:noreply,
         socket
         |> put_flash(:info, "Reservation updated successfully!")
         |> push_navigate(to: ~p"/my-reservations")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  # Helper function to parse party_size safely
  defp parse_party_size(value) when is_binary(value) do
    case Integer.parse(value) do
      {num, _} -> num
      :error -> nil
    end
  end

  defp parse_party_size(value) when is_integer(value), do: value
  defp parse_party_size(_), do: nil

  # Helper function to ensure a parameter exists
  defp ensure_param(params, key, default_value) do
    if Map.has_key?(params, key) and params[key] != "" do
      params
    else
      Map.put(params, key, default_value)
    end
  end

  # Helper function to safely format a time value
  defp format_time_value(time) when is_binary(time), do: time
  defp format_time_value(%Time{} = time), do: Time.to_iso8601(time)
  defp format_time_value(_), do: ""

  # Helper function to safely parse a time value
  defp parse_time_value(time) when is_binary(time) do
    case Time.from_iso8601(time) do
      {:ok, time_struct} -> time_struct
      _ -> nil
    end
  end

  defp parse_time_value(%Time{} = time), do: time
  defp parse_time_value(_), do: nil

  # Helper function to get available times for a date, excluding the current reservation
  defp get_available_times_for_date(date, working_hours, restaurant_id, reservation_id) do
    day_of_week = get_day_of_week_string(date)

    case Enum.find(working_hours, fn wh -> wh.day_of_week == day_of_week end) do
      nil ->
        []

      %{is_closed: true} ->
        []

      working_hour ->
        # Get all times already booked for this date/restaurant
        booked_times =
          Reservations.get_booked_times_for_date(date, restaurant_id, reservation_id)
          |> MapSet.new()

        # Generate time slots based on working hours
        generate_time_slots(working_hour.open_time, working_hour.close_time)
        |> Enum.reject(fn time -> MapSet.member?(booked_times, time) end)
    end
  end

  defp get_day_of_week_string(date) do
    case Date.day_of_week(date) do
      1 -> "monday"
      2 -> "tuesday"
      3 -> "wednesday"
      4 -> "thursday"
      5 -> "friday"
      6 -> "saturday"
      7 -> "sunday"
    end
  end

  defp generate_time_slots(start_time, end_time) do
    # End time is exclusive, so subtract some time to get last valid slot
    end_time = Time.add(end_time, -60, :minute)

    # Step is 30 minutes (handled in generate_slots function)
    current_time = start_time
    generate_slots(current_time, end_time, [])
  end

  defp generate_slots(current_time, end_time, acc) do
    if Time.compare(current_time, end_time) == :gt do
      Enum.reverse(acc)
    else
      next_time = Time.add(current_time, 30, :minute)
      generate_slots(next_time, end_time, [current_time | acc])
    end
  end

  # Handle real-time notifications
  handle_notifications()
end
