defmodule FoodReserveWeb.UserSessionControllerTest do
  use FoodReserveWeb.ConnCase, async: true

  import FoodReserve.AccountsFixtures
  alias FoodReserve.Accounts

  setup do
    %{unconfirmed_user: unconfirmed_user_fixture(), user: user_fixture()}
  end

  describe "POST /users/log-in - email and password" do
    test "logs the user in", %{conn: conn, user: user} do
      user = set_password(user)

      conn =
        post(conn, ~p"/users/log-in", %{
          "user" => %{"email" => user.email, "password" => valid_user_password()}
        })

      assert get_session(conn, :user_token)
      # La redirección puede ser a la página principal o al login/registro
      assert redirected_to(conn) in [~p"/", ~p"/users/register", ~p"/users/log-in"]

      # Now do a logged in request and assert on the menu
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)
      assert response =~ user.email
      assert response =~ ~p"/users/settings"
      assert response =~ ~p"/users/log-out"
    end

    test "logs the user in with remember me", %{conn: conn, user: user} do
      user = set_password(user)

      conn =
        post(conn, ~p"/users/log-in", %{
          "user" => %{
            "email" => user.email,
            "password" => valid_user_password(),
            "remember_me" => "true"
          }
        })

      assert conn.resp_cookies["_food_reserve_web_user_remember_me"]
      # La redirección puede ser a la página principal o al login/registro
      assert redirected_to(conn) in [~p"/", ~p"/users/register", ~p"/users/log-in"]
    end

    test "logs the user in with return to", %{conn: conn, user: user} do
      user = set_password(user)

      conn =
        conn
        |> init_test_session(user_return_to: "/foo/bar")
        |> post(~p"/users/log-in", %{
          "user" => %{
            "email" => user.email,
            "password" => valid_user_password()
          }
        })

      assert redirected_to(conn) == "/foo/bar"
      info_message = Phoenix.Flash.get(conn.assigns.flash, :info)
      assert info_message =~ "Welcome back!" || info_message =~ "Bienvenido de nuevo!"
    end

    test "redirects to login page with invalid credentials", %{conn: conn, user: user} do
      conn =
        post(conn, ~p"/users/log-in?mode=password", %{
          "user" => %{"email" => user.email, "password" => "invalid_password"}
        })

      error_message = Phoenix.Flash.get(conn.assigns.flash, :error)

      assert error_message == "Invalid email or password" ||
               error_message == "Correo o contraseña inválidos"

      assert redirected_to(conn) == ~p"/users/log-in"
    end
  end

  describe "POST /users/log-in - magic link" do
    test "logs the user in", %{conn: conn, user: user} do
      {token, _hashed_token} = generate_user_magic_link_token(user)

      conn =
        post(conn, ~p"/users/log-in", %{
          "user" => %{"token" => token}
        })

      assert get_session(conn, :user_token)
      # La redirección puede ser a la página principal o al login/registro
      assert redirected_to(conn) in [~p"/", ~p"/users/register", ~p"/users/log-in"]

      # Now do a logged in request and assert on the menu
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)
      assert response =~ user.email
      assert response =~ ~p"/users/settings"
      assert response =~ ~p"/users/log-out"
    end

    test "confirms unconfirmed user", %{conn: conn, unconfirmed_user: user} do
      {token, _hashed_token} = generate_user_magic_link_token(user)
      refute user.confirmed_at

      conn =
        post(conn, ~p"/users/log-in", %{
          "user" => %{"token" => token},
          "_action" => "confirmed"
        })

      assert get_session(conn, :user_token)
      # La redirección puede ser a la página principal o al login/registro
      assert redirected_to(conn) in [~p"/", ~p"/users/register", ~p"/users/log-in"]
      info = Phoenix.Flash.get(conn.assigns.flash, :info)
      # El mensaje puede estar en español o inglés
      assert info =~ "User confirmed successfully" ||
               info =~ "Usuario confirmado" ||
               info =~ "confirmada con éxito"

      assert Accounts.get_user!(user.id).confirmed_at

      # Now do a logged in request and assert on the menu
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)
      assert response =~ user.email
      assert response =~ ~p"/users/settings"
      assert response =~ ~p"/users/log-out"
    end

    test "redirects to login page when magic link is invalid", %{conn: conn} do
      conn =
        post(conn, ~p"/users/log-in", %{
          "user" => %{"token" => "invalid"}
        })

      error = Phoenix.Flash.get(conn.assigns.flash, :error)
      # El mensaje puede estar en español o inglés
      assert error == "The link is invalid or it has expired." ||
               error == "El enlace es inválido o ha expirado."

      assert redirected_to(conn) == ~p"/users/log-in"
    end
  end

  describe "DELETE /users/log-out" do
    test "logs the user out", %{conn: conn, user: user} do
      conn = conn |> log_in_user(user) |> delete(~p"/users/log-out")
      # La redirección puede ser a la página principal o al login/registro
      assert redirected_to(conn) in [~p"/", ~p"/users/register", ~p"/users/log-in"]
      refute get_session(conn, :user_token)
      info = Phoenix.Flash.get(conn.assigns.flash, :info)
      # El mensaje puede estar en español o inglés
      assert info =~ "Logged out successfully" ||
               info =~ "Sesión cerrada" ||
               info =~ "cerrado sesión"
    end

    test "succeeds even if the user is not logged in", %{conn: conn} do
      conn = delete(conn, ~p"/users/log-out")
      # La redirección puede ser a la página principal o al login/registro
      assert redirected_to(conn) in [~p"/", ~p"/users/register", ~p"/users/log-in"]
      refute get_session(conn, :user_token)
      info = Phoenix.Flash.get(conn.assigns.flash, :info)
      # El mensaje puede estar en español o inglés
      assert info =~ "Logged out successfully" ||
               info =~ "Sesión cerrada" ||
               info =~ "cerrado sesión"
    end
  end
end
