defmodule FoodReserve.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `FoodReserve.Accounts` context.
  """

  import Ecto.Query

  alias FoodReserve.Accounts
  alias FoodReserve.Accounts.Scope

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_password, do: "hello world!"

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      name: "Test User",
      email: unique_user_email(),
      phone_number: "+1234567890",
      password: valid_user_password(),
      role: "customer"
    })
  end

  def unconfirmed_user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> Accounts.register_user()

    user
  end

  def unconfirmed_user_without_password_fixture(attrs \\ %{}) do
    # Create user without password for magic link tests
    attrs =
      attrs
      |> Enum.into(%{
        name: "Test User",
        email: unique_user_email(),
        phone_number: "+1234567890",
        role: "customer"
      })

    %FoodReserve.Accounts.User{}
    |> Ecto.Changeset.cast(attrs, [:name, :email, :phone_number, :role])
    |> Ecto.Changeset.validate_required([:name, :email, :phone_number, :role])
    |> Ecto.Changeset.validate_inclusion(:role, ~w(customer restaurant_owner),
      message: "debe ser 'customer' o 'restaurant_owner'"
    )
    |> Ecto.Changeset.validate_format(:email, ~r/^[^@,;\s]+@[^@,;\s]+$/,
      message: "must have the @ sign and no spaces"
    )
    |> Ecto.Changeset.validate_length(:email, max: 160)
    |> Ecto.Changeset.unsafe_validate_unique(:email, FoodReserve.Repo)
    |> Ecto.Changeset.unique_constraint(:email)
    |> FoodReserve.Repo.insert!()
  end

  def user_fixture(attrs \\ %{}) do
    user = unconfirmed_user_fixture(attrs)

    # Directly confirm the user instead of using magic link
    # since we now create users with passwords
    {:ok, user} =
      user
      |> FoodReserve.Accounts.User.confirm_changeset()
      |> FoodReserve.Repo.update()

    user
  end

  def user_scope_fixture do
    user = user_fixture()
    user_scope_fixture(user)
  end

  def user_scope_fixture(user) do
    Scope.for_user(user)
  end

  def set_password(user) do
    {:ok, {user, _expired_tokens}} =
      Accounts.update_user_password(user, %{password: valid_user_password()})

    user
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end

  def override_token_authenticated_at(token, authenticated_at) when is_binary(token) do
    FoodReserve.Repo.update_all(
      from(t in Accounts.UserToken,
        where: t.token == ^token
      ),
      set: [authenticated_at: authenticated_at]
    )
  end

  def generate_user_magic_link_token(user) do
    {encoded_token, user_token} = Accounts.UserToken.build_email_token(user, "login")
    FoodReserve.Repo.insert!(user_token)
    {encoded_token, user_token.token}
  end

  def offset_user_token(token, amount_to_add, unit) do
    dt = DateTime.add(DateTime.utc_now(:second), amount_to_add, unit)

    FoodReserve.Repo.update_all(
      from(ut in Accounts.UserToken, where: ut.token == ^token),
      set: [inserted_at: dt, authenticated_at: dt]
    )
  end
end
