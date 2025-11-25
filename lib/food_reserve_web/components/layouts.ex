defmodule FoodReserveWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use FoodReserveWeb, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  attr :unread_notifications_count, :integer,
    default: 0,
    doc: "the count of unread notifications for the current user"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <header
      class="bg-white shadow-sm"
      x-data="{ mobileMenuOpen: false }"
      @click.outside="mobileMenuOpen = false"
      @keydown.escape="mobileMenuOpen = false"
    >
      <nav class="container mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <!-- Logo -->
          <div class="flex items-center">
            <a href="/" class="flex items-center gap-2 text-xl font-bold text-gray-800">
              <img src={~p"/images/logo.svg"} width="32" />
              <span>FoodReserve</span>
            </a>
          </div>
          
    <!-- Desktop Navigation -->
          <div class="hidden md:flex items-center space-x-4">
            <%= if @current_scope && @current_scope.user do %>
              <div class="relative" x-data="{ userMenuOpen: false }">
                <button
                  @click="userMenuOpen = !userMenuOpen"
                  class="flex items-center space-x-2 focus:outline-none"
                >
                  <span class="font-semibold text-gray-700">Hola, {@current_scope.user.name}</span>
                  <.icon name="hero-chevron-down" class="w-4 h-4 text-gray-600" />
                </button>
                <div
                  x-show="userMenuOpen"
                  @click.away="userMenuOpen = false"
                  class="absolute right-0 mt-2 w-48 bg-white rounded-lg shadow-xl z-20"
                  x-transition
                  x-cloak
                >
                  <.link
                    navigate={~p"/restaurants"}
                    class="block px-4 py-2 text-gray-800 hover:bg-orange-100 rounded-t-lg"
                  >
                    Mis Restaurantes
                  </.link>
                  <.link
                    navigate={~p"/notifications"}
                    class="flex items-center justify-between px-4 py-2 text-gray-800 hover:bg-orange-100"
                  >
                    <span>Notificaciones</span>
                    <%= if assigns[:unread_notifications_count] && @unread_notifications_count > 0 do %>
                      <span class="inline-flex items-center justify-center px-2 py-1 text-xs font-bold leading-none text-white bg-red-600 rounded-full">
                        {@unread_notifications_count}
                      </span>
                    <% end %>
                  </.link>
                  <.link
                    navigate={~p"/users/settings"}
                    class="block px-4 py-2 text-gray-800 hover:bg-orange-100"
                  >
                    Ajustes
                  </.link>
                  <.link
                    href={~p"/users/log-out"}
                    method="delete"
                    class="block px-4 py-2 text-gray-800 hover:bg-orange-100 rounded-b-lg"
                  >
                    Cerrar Sesión
                  </.link>
                </div>
              </div>
            <% else %>
              <.link navigate={~p"/users/log-in"} class="text-gray-600 hover:text-gray-800">
                Iniciar Sesión
              </.link>
              <.link
                navigate={~p"/users/register"}
                class="bg-orange-500 hover:bg-orange-600 text-white font-bold py-2 px-4 rounded-lg"
              >
                Registrarse
              </.link>
            <% end %>
            <.theme_toggle />
          </div>
          
    <!-- Mobile menu button -->
          <div class="md:hidden flex items-center space-x-2">
            <.theme_toggle />
            <button
              @click.stop="mobileMenuOpen = !mobileMenuOpen"
              type="button"
              class="inline-flex items-center justify-center p-2 rounded-md text-gray-600 hover:text-gray-800 hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-orange-500"
            >
              <span class="sr-only">Abrir menú principal</span>
              <!-- Hamburger icon -->
              <svg
                x-show="!mobileMenuOpen"
                class="block h-6 w-6"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M4 6h16M4 12h16M4 18h16"
                />
              </svg>
              <!-- Close icon -->
              <svg
                x-show="mobileMenuOpen"
                class="block h-6 w-6"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
                x-cloak
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M6 18L18 6M6 6l12 12"
                />
              </svg>
            </button>
          </div>
        </div>
        
    <!-- Mobile menu -->
        <div
          x-show="mobileMenuOpen"
          class="md:hidden"
          x-transition:enter="transition ease-out duration-200"
          x-transition:enter-start="opacity-0 transform -translate-y-2"
          x-transition:enter-end="opacity-100 transform translate-y-0"
          x-transition:leave="transition ease-in duration-150"
          x-transition:leave-start="opacity-100 transform translate-y-0"
          x-transition:leave-end="opacity-0 transform -translate-y-2"
          x-cloak
        >
          <div class="px-2 pt-2 pb-3 space-y-1 bg-white border-t border-gray-200">
            <%= if @current_scope && @current_scope.user do %>
              <div class="px-3 py-2 text-sm font-medium text-gray-500 border-b border-gray-200">
                Hola, {@current_scope.user.name}
              </div>
              <a
                href={~p"/restaurants"}
                class="block px-3 py-2 text-base font-medium text-gray-700 hover:text-gray-900 hover:bg-gray-50"
                @click="mobileMenuOpen = false"
              >
                Mis Restaurantes
              </a>
              <a
                href={~p"/users/settings"}
                class="block px-3 py-2 text-base font-medium text-gray-700 hover:text-gray-900 hover:bg-gray-50"
                @click="mobileMenuOpen = false"
              >
                Ajustes
              </a>
              <form action={~p"/users/log-out"} method="post" class="block">
                <input type="hidden" name="_method" value="delete" />
                <input type="hidden" name="_csrf_token" value={Plug.CSRFProtection.get_csrf_token()} />
                <button
                  type="submit"
                  class="w-full text-left px-3 py-2 text-base font-medium text-gray-700 hover:text-gray-900 hover:bg-gray-50"
                  @click="mobileMenuOpen = false"
                >
                  Cerrar Sesión
                </button>
              </form>
            <% else %>
              <a
                href={~p"/users/log-in"}
                class="block px-3 py-2 text-base font-medium text-gray-700 hover:text-gray-900 hover:bg-gray-50"
                @click="mobileMenuOpen = false"
              >
                Iniciar Sesión
              </a>
              <a
                href={~p"/users/register"}
                class="block px-3 py-2 text-base font-medium bg-orange-500 text-white hover:bg-orange-600 rounded-lg mx-3"
                @click="mobileMenuOpen = false"
              >
                Registrarse
              </a>
            <% end %>
          </div>
        </div>
      </nav>
    </header>

    <main>
      {render_slot(@inner_block)}
    </main>

    <.flash_group flash={@flash} />
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.

  See <head> in root.html.heex which applies the theme before page load.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="card relative flex flex-row items-center border-2 border-base-300 bg-base-300 rounded-full">
      <div class="absolute w-1/3 h-full rounded-full border-1 border-base-200 bg-base-100 brightness-200 left-0 [[data-theme=light]_&]:left-1/3 [[data-theme=dark]_&]:left-2/3 transition-[left]" />

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="system"
      >
        <.icon name="hero-computer-desktop-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="light"
      >
        <.icon name="hero-sun-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="dark"
      >
        <.icon name="hero-moon-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
    </div>
    """
  end
end
