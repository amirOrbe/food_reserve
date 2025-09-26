defmodule FoodReserveWeb.HomeLive do
  use FoodReserveWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div class="bg-gray-50">
      <section class="bg-white">
        <div class="container mx-auto px-4 sm:px-6 lg:px-8 py-20 text-center">
          <h1 class="text-4xl md:text-5xl font-extrabold text-gray-900 leading-tight mb-4">
            Your next favorite meal, <span class="text-orange-500">one click away.</span>
          </h1>
          <p class="text-lg text-gray-600 mb-8 max-w-2xl mx-auto">
            Discover and reserve from the best local restaurants. Order ahead and have your food ready when you arrive.
          </p>
          <div class="max-w-xl mx-auto">
            <div class="flex items-center bg-white rounded-full shadow-md p-2">
              <input type="text" placeholder="Search for a dish or restaurant..." class="w-full bg-transparent border-none focus:ring-0 text-lg px-4" />
              <.button variant="primary" class="rounded-full">Search</.button>
            </div>
          </div>
        </div>
      </section>

      <section class="py-16">
        <div class="container mx-auto px-4 sm:px-6 lg:px-8">
          <h2 class="text-3xl font-bold text-center text-gray-800 mb-10">Featured Restaurants</h2>
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            <!-- Example Restaurant Card -->
            <div class="bg-white rounded-2xl shadow-lg overflow-hidden transform hover:-translate-y-1 transition-transform duration-300">
              <img src="https://images.unsplash.com/photo-1555396273-367ea4eb4db5?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1074&q=80" alt="The Cozy Italian" class="w-full h-48 object-cover"/>
              <div class="p-6">
                <h3 class="text-xl font-bold mb-2">The Cozy Italian</h3>
                <p class="text-gray-600 mb-4">Italian Cuisine</p>
                <div class="flex items-center">
                  <.icon name="hero-star-solid" class="w-5 h-5 text-yellow-400" />
                  <.icon name="hero-star-solid" class="w-5 h-5 text-yellow-400" />
                  <.icon name="hero-star-solid" class="w-5 h-5 text-yellow-400" />
                  <.icon name="hero-star-solid" class="w-5 h-5 text-yellow-400" />
                  <.icon name="hero-star" class="w-5 h-5 text-yellow-400" />
                  <span class="ml-2 text-gray-500">4.0 (124 reviews)</span>
                </div>
              </div>
            </div>
            <!-- Add more cards here -->
          </div>
        </div>
      </section>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :page_title, "Home")}
  end
end
