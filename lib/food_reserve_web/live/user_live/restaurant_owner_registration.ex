defmodule FoodReserveWeb.UserLive.RestaurantOwnerRegistration do
  use FoodReserveWeb, :live_view

  alias FoodReserve.Accounts
  alias FoodReserve.Accounts.User

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="min-h-screen bg-gray-50 flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
        <div class="max-w-md w-full mx-auto">
          <div class="bg-white p-8 rounded-2xl shadow-lg">
            <div class="text-center mb-6">
              <.header>
                Registro de Dueño de Restaurante
                <:subtitle>
                  Crea tu cuenta para administrar tu restaurante
                </:subtitle>
              </.header>
            </div>

            <.form
              for={@form}
              id="restaurant_owner_registration_form"
              phx-submit="save"
              phx-change="validate"
            >
              <.input
                field={@form[:name]}
                type="text"
                label="Nombre Completo"
                required
                phx-mounted={JS.focus()}
              />
              <.input field={@form[:email]} type="email" label="Correo Electrónico" required />
              <.input field={@form[:phone_number]} type="tel" label="Número de Teléfono" required />
              <.input field={@form[:password]} type="password" label="Contraseña" required />

              <div class="bg-orange-50 border border-orange-200 rounded-lg p-4 mb-4">
                <div class="flex items-start">
                  <svg
                    class="w-5 h-5 text-orange-600 mt-0.5 mr-3"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                    />
                  </svg>
                  <div>
                    <h4 class="text-sm font-medium text-orange-800 mb-1">Información importante</h4>
                    <p class="text-sm text-orange-700">
                      Una vez creada tu cuenta, podrás registrar tu restaurante y comenzar a administrar reservas y menús.
                    </p>
                  </div>
                </div>
              </div>

              <div class="pt-4">
                <button
                  type="submit"
                  phx-disable-with="Creando cuenta..."
                  class="w-full bg-orange-600 hover:bg-orange-700 text-white font-bold py-3 px-4 rounded-lg"
                  style="background-color: #ea580c; color: white; padding: 12px 16px; border-radius: 8px; border: none; cursor: pointer; font-weight: bold; width: 100%;"
                >
                  Crear cuenta de restaurante
                </button>
              </div>
            </.form>

            <div class="text-center mt-4">
              <p class="text-sm text-gray-500">
                <.link
                  navigate={~p"/users/register"}
                  class="font-semibold text-orange-500 hover:underline"
                >
                  ← Volver a selección de tipo
                </.link>
              </p>
            </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, %{assigns: %{current_scope: %{user: user}}} = socket)
      when not is_nil(user) do
    {:ok, redirect(socket, to: FoodReserveWeb.UserAuth.signed_in_path(socket))}
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{}, %{"role" => "restaurant_owner"})
    {:ok, assign_form(socket, changeset), temporary_assigns: [form: nil]}
  end

  @impl true
  def handle_event("save", %{"user" => user_params}, socket) do
    user_params = Map.put(user_params, "role", "restaurant_owner")

    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_login_instructions(
            user,
            &url(~p"/users/log-in/#{&1}")
          )

        {:noreply,
         socket
         |> put_flash(
           :info,
           "¡Cuenta creada exitosamente! Se ha enviado un email a #{user.email} para confirmar tu cuenta. Una vez confirmada, podrás registrar tu restaurante."
         )
         |> push_navigate(to: ~p"/users/log-in")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    user_params = Map.put(user_params, "role", "restaurant_owner")
    changeset = Accounts.change_user_registration(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")
    assign(socket, form: form)
  end
end
