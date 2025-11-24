defmodule FoodReserveWeb.UserLive.RoleSelection do
  use FoodReserveWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="min-h-screen bg-gradient-to-br from-slate-50 to-gray-100">
        
    <!-- Background decoration -->
        <div class="absolute inset-0 overflow-hidden pointer-events-none">
          <div class="absolute -top-40 -right-32 w-80 h-80 bg-orange-100 rounded-full opacity-20 blur-3xl">
          </div>
          <div class="absolute -bottom-40 -left-32 w-80 h-80 bg-blue-100 rounded-full opacity-20 blur-3xl">
          </div>
        </div>

        <div class="relative max-w-6xl mx-auto px-6 py-16">
          
    <!-- Header -->
          <div class="text-center mb-20">
            <div class="inline-flex items-center justify-center w-16 h-16 bg-gradient-to-br from-orange-500 to-orange-600 rounded-2xl mb-8 shadow-lg">
              <svg class="w-8 h-8 text-white" fill="currentColor" viewBox="0 0 24 24">
                <path d="M8.1,13.34L3.91,9.16C2.35,7.59 2.35,5.06 3.91,3.5L10.93,10.5L8.1,13.34M13.41,13L20.29,19.88L18.88,21.29L12,14.41L5.12,21.29L3.71,19.88L13.36,10.22L13.16,10C12.38,9.23 12.38,7.97 13.16,7.19L17.5,2.82L18.43,3.74L15.19,7L16.15,7.94L19.39,4.69L20.32,5.61L15.91,10.02C15.13,10.8 13.87,10.8 13.09,10.02L13.41,13Z" />
              </svg>
            </div>
            <h1 class="text-4xl md:text-5xl font-bold text-gray-900 mb-4">
              ¡Bienvenido a Food Reserve!
            </h1>
            <p class="text-xl text-gray-600 max-w-2xl mx-auto">
              Elige cómo quieres comenzar tu experiencia culinaria
            </p>
          </div>
          
    <!-- Options -->
          <div class="grid lg:grid-cols-2 gap-8 mb-16">
            
    <!-- Cliente -->
            <div
              class="group cursor-pointer transform hover:scale-105 transition-all duration-300"
              phx-click="select_role"
              phx-value-role="customer"
            >
              <div class="relative bg-white rounded-3xl p-8 shadow-xl hover:shadow-2xl transition-all duration-500 overflow-hidden border border-gray-100">
                
    <!-- Background gradient on hover -->
                <div class="absolute inset-0 bg-gradient-to-br from-blue-50 to-blue-100 opacity-0 group-hover:opacity-100 transition-opacity duration-500">
                </div>
                
    <!-- Content -->
                <div class="relative z-10">
                  <!-- Icon -->
                  <div class="inline-flex items-center justify-center w-20 h-20 bg-gradient-to-br from-blue-500 to-blue-600 rounded-2xl mb-6 shadow-lg group-hover:shadow-xl group-hover:scale-110 transition-all duration-300">
                    <svg
                      class="w-10 h-10 text-white"
                      fill="none"
                      stroke="currentColor"
                      viewBox="0 0 24 24"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M17.982 18.725A7.488 7.488 0 0012 15.75a7.488 7.488 0 00-5.982 2.975m11.963 0a9 9 0 10-11.963 0m11.963 0A8.966 8.966 0 0112 21a8.966 8.966 0 01-5.982-2.275M15 9.75a3 3 0 11-6 0 3 3 0 016 0z"
                      />
                    </svg>
                  </div>
                  
    <!-- Badge -->
                  <div class="inline-block px-3 py-1 bg-blue-100 text-blue-800 text-sm font-medium rounded-full mb-4">
                    Para Comensales
                  </div>
                  
    <!-- Title -->
                  <h3 class="text-2xl font-bold text-gray-900 mb-4">
                    Soy Cliente
                  </h3>
                  
    <!-- Description -->
                  <p class="text-gray-600 text-lg leading-relaxed mb-6">
                    Descubre restaurantes increíbles, explora menús deliciosos y reserva tu mesa favorita en segundos.
                  </p>
                  
    <!-- Features -->
                  <div class="space-y-3 mb-8">
                    <div class="flex items-center text-gray-700">
                      <div class="w-2 h-2 bg-blue-500 rounded-full mr-3"></div>
                      <span>Buscar restaurantes cercanos</span>
                    </div>
                    <div class="flex items-center text-gray-700">
                      <div class="w-2 h-2 bg-blue-500 rounded-full mr-3"></div>
                      <span>Ver menús y precios</span>
                    </div>
                    <div class="flex items-center text-gray-700">
                      <div class="w-2 h-2 bg-blue-500 rounded-full mr-3"></div>
                      <span>Reservar instantáneamente</span>
                    </div>
                  </div>
                  
    <!-- CTA -->
                  <div class="flex items-center justify-between">
                    <span class="text-blue-600 font-semibold text-lg group-hover:text-blue-700 transition-colors">
                      Comenzar ahora
                    </span>
                    <svg
                      class="w-6 h-6 text-blue-600 group-hover:translate-x-1 transition-transform"
                      fill="none"
                      stroke="currentColor"
                      viewBox="0 0 24 24"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M13 7l5 5m0 0l-5 5m5-5H6"
                      />
                    </svg>
                  </div>
                </div>
              </div>
            </div>
            
    <!-- Dueño de Restaurante -->
            <div
              class="group cursor-pointer transform hover:scale-105 transition-all duration-300"
              phx-click="select_role"
              phx-value-role="restaurant_owner"
            >
              <div class="relative bg-white rounded-3xl p-8 shadow-xl hover:shadow-2xl transition-all duration-500 overflow-hidden border border-gray-100">
                
    <!-- Background gradient on hover -->
                <div class="absolute inset-0 bg-gradient-to-br from-orange-50 to-orange-100 opacity-0 group-hover:opacity-100 transition-opacity duration-500">
                </div>
                
    <!-- Content -->
                <div class="relative z-10">
                  <!-- Icon -->
                  <div class="inline-flex items-center justify-center w-20 h-20 bg-gradient-to-br from-orange-500 to-orange-600 rounded-2xl mb-6 shadow-lg group-hover:shadow-xl group-hover:scale-110 transition-all duration-300">
                    <svg
                      class="w-10 h-10 text-white"
                      fill="none"
                      stroke="currentColor"
                      viewBox="0 0 24 24"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-4m-5 0H3m2 0h3M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"
                      />
                    </svg>
                  </div>
                  
    <!-- Badge -->
                  <div class="inline-block px-3 py-1 bg-orange-100 text-orange-800 text-sm font-medium rounded-full mb-4">
                    Para Restaurantes
                  </div>
                  
    <!-- Title -->
                  <h3 class="text-2xl font-bold text-gray-900 mb-4">
                    Tengo un Restaurante
                  </h3>
                  
    <!-- Description -->
                  <p class="text-gray-600 text-lg leading-relaxed mb-6">
                    Lleva tu restaurante al siguiente nivel. Gestiona reservas, actualiza menús y conecta con más clientes.
                  </p>
                  
    <!-- Features -->
                  <div class="space-y-3 mb-8">
                    <div class="flex items-center text-gray-700">
                      <div class="w-2 h-2 bg-orange-500 rounded-full mr-3"></div>
                      <span>Registrar tu restaurante</span>
                    </div>
                    <div class="flex items-center text-gray-700">
                      <div class="w-2 h-2 bg-orange-500 rounded-full mr-3"></div>
                      <span>Gestionar menús y precios</span>
                    </div>
                    <div class="flex items-center text-gray-700">
                      <div class="w-2 h-2 bg-orange-500 rounded-full mr-3"></div>
                      <span>Administrar reservaciones</span>
                    </div>
                  </div>
                  
    <!-- CTA -->
                  <div class="flex items-center justify-between">
                    <span class="text-orange-600 font-semibold text-lg group-hover:text-orange-700 transition-colors">
                      Comenzar ahora
                    </span>
                    <svg
                      class="w-6 h-6 text-orange-600 group-hover:translate-x-1 transition-transform"
                      fill="none"
                      stroke="currentColor"
                      viewBox="0 0 24 24"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M13 7l5 5m0 0l-5 5m5-5H6"
                      />
                    </svg>
                  </div>
                </div>
              </div>
            </div>
          </div>
          
    <!-- Login Link -->
          <div class="text-center">
            <p class="text-gray-600">
              ¿Ya tienes una cuenta?
              <.link
                navigate={~p"/users/log-in"}
                class="text-orange-600 hover:text-orange-700 font-semibold transition-colors ml-1 hover:underline"
              >
                Inicia sesión aquí
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
    {:ok, socket}
  end

  @impl true
  def handle_event("select_role", %{"role" => role}, socket) do
    case role do
      "customer" ->
        {:noreply, push_navigate(socket, to: ~p"/users/register/customer")}

      "restaurant_owner" ->
        {:noreply, push_navigate(socket, to: ~p"/users/register/restaurant-owner")}

      _ ->
        {:noreply, socket}
    end
  end
end
