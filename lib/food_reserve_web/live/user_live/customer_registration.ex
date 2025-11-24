defmodule FoodReserveWeb.UserLive.CustomerRegistration do
  use FoodReserveWeb, :live_view

  alias FoodReserve.Accounts
  alias FoodReserve.Accounts.User

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="mx-auto max-w-sm">
        <div class="bg-white p-8 rounded-2xl shadow-lg w-full max-w-md">
          <div class="text-center mb-6">
            <.header>
              Registro de Cliente
              <:subtitle>
                Crea tu cuenta para explorar restaurantes
              </:subtitle>
            </.header>
          </div>

          <.form for={@form} id="customer_registration_form" phx-submit="save" phx-change="validate">
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

            <div class="pt-4">
              <button
                type="submit"
                phx-disable-with="Creando cuenta..."
                class="w-full bg-blue-600 hover:bg-blue-700 text-white font-bold py-3 px-4 rounded-lg"
                style="background-color: #2563eb; color: white; padding: 12px 16px; border-radius: 8px; border: none; cursor: pointer; font-weight: bold; width: 100%;"
              >
                Crear cuenta de cliente
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
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, %{assigns: %{current_scope: %{user: user}}} = socket)
      when not is_nil(user) do
    {:ok, redirect(socket, to: FoodReserveWeb.UserAuth.signed_in_path(socket))}
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{}, %{"role" => "customer"})
    {:ok, assign_form(socket, changeset), temporary_assigns: [form: nil]}
  end

  @impl true
  def handle_event("save", %{"user" => user_params}, socket) do
    user_params = Map.put(user_params, "role", "customer")

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
           "¡Cuenta creada exitosamente! Se ha enviado un email a #{user.email} para confirmar tu cuenta."
         )
         |> push_navigate(to: ~p"/users/log-in")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    user_params = Map.put(user_params, "role", "customer")
    changeset = Accounts.change_user_registration(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")
    assign(socket, form: form)
  end
end
