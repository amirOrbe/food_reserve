defmodule FoodReserveWeb.UserLive.Login do
  use FoodReserveWeb, :live_view

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="min-h-screen bg-gray-50 flex items-center justify-center py-8 sm:py-12 px-4 sm:px-6 lg:px-8">
        <div class="max-w-sm sm:max-w-md w-full mx-auto">
          <div class="bg-white p-6 sm:p-8 rounded-xl sm:rounded-2xl shadow-lg">
            <div class="text-center mb-6">
              <.header>
                Iniciar Sesión
                <:subtitle>
                  ¿No tienes una cuenta?
                  <.link
                    navigate={~p"/users/register"}
                    class="font-semibold text-orange-500 hover:underline"
                  >
                    Regístrate
                  </.link>
                  ahora.
                </:subtitle>
              </.header>
            </div>

            <.form for={@form} action={~p"/users/log-in"} method="post">
              <.input field={@form[:email]} type="email" label="Correo Electrónico" required />
              <.input field={@form[:password]} type="password" label="Contraseña" required />

              <div class="pt-4">
                <button
                  type="submit"
                  class="w-full bg-orange-600 hover:bg-orange-700 text-white font-bold py-3 px-4 rounded-lg"
                  style="background-color: #ea580c; color: white; padding: 12px 16px; border-radius: 8px; border: none; cursor: pointer; font-weight: bold; width: 100%;"
                >
                  Iniciar Sesión <span aria-hidden="true">→</span>
                </button>
              </div>
            </.form>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form)}
  end
end
