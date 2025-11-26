defmodule FoodReserveWeb.Router do
  use FoodReserveWeb, :router

  import FoodReserveWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {FoodReserveWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Other scopes may use custom stacks.
  # scope "/api", FoodReserveWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:food_reserve, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: FoodReserveWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", FoodReserveWeb do
    pipe_through [:browser, :require_authenticated_user]

    # Routes only for restaurant owners (must come first for specificity)
    live_session :restaurant_owners_only,
      on_mount: [{FoodReserveWeb.UserAuth, :require_restaurant_owner}] do
      live "/restaurants/new", RestaurantLive.Form, :new
      live "/restaurants/:id/edit", RestaurantLive.Form, :edit
      live "/restaurants/:restaurant_id/menu", MenuLive.Index, :index
      live "/restaurants/:restaurant_id/menu/new", MenuLive.Form, :new
      live "/restaurants/:restaurant_id/menu/:id/edit", MenuLive.Form, :edit
      live "/restaurants/:restaurant_id/hours", WorkingHoursLive.Index, :index
      live "/restaurants/:restaurant_id/reservations", ReservationLive.Manage, :index
      live "/restaurants/orders", OrderLive.Manage, :index
    end

    live_session :require_authenticated_user,
      on_mount: [{FoodReserveWeb.UserAuth, :require_authenticated}] do
      live "/", HomeLive, :index

      live "/users/settings", UserLive.Settings, :edit
      live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email

      # Routes accessible to all authenticated users (customers can view restaurants)
      live "/restaurants", RestaurantLive.Index, :index
      live "/restaurants/:id", RestaurantLive.Show, :show

      # Reservation routes (for customers)
      live "/restaurants/:restaurant_id/reserve", ReservationLive.New, :new
      live "/my-reservations", ReservationLive.Index, :index
      live "/reservations/:id/edit", ReservationLive.Edit, :edit
      live "/restaurants/:restaurant_id/review", ReviewLive.New, :new
      live "/reservations/:reservation_id/review", ReviewLive.Prompt, :show
      live "/reservations/:reservation_id/review-prompt", ReviewLive.AfterVisit, :new
      live "/notifications", NotificationLive.Index, :index

      # Order routes
      live "/reservations/:reservation_id/order", OrderLive.New, :new

      post "/users/update-password", UserSessionController, :update_password
    end
  end

  scope "/", FoodReserveWeb do
    pipe_through [:browser]

    live_session :current_user,
      on_mount: [{FoodReserveWeb.UserAuth, :mount_current_scope}] do
      # Nueva página de selección de rol
      live "/users/register", UserLive.RoleSelection, :new

      # Formularios de registro específicos por rol
      live "/users/register/customer", UserLive.CustomerRegistration, :new
      live "/users/register/restaurant-owner", UserLive.RestaurantOwnerRegistration, :new

      # Login y confirmación
      live "/users/log-in", UserLive.Login, :new
      live "/users/log-in/:token", UserLive.Confirmation, :new
    end

    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end
end
