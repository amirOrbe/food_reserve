defmodule FoodReserveWeb.UserLive.Login do
  use FoodReserveWeb, :live_view

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="mx-auto max-w-sm">
        <div class="bg-white p-8 rounded-2xl shadow-lg w-full max-w-md">
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
              <.button class="w-full bg-orange-500 hover:bg-orange-600 text-white font-bold py-3 px-4 rounded-lg">
                Iniciar Sesión <span aria-hidden="true">→</span>
              </.button>
            </div>
          </.form>
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
