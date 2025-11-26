defmodule FoodReserve.Menus do
  @moduledoc """
  The Menus context.
  """

  import Ecto.Query, warn: false
  alias FoodReserve.Repo

  alias FoodReserve.Menus.Menu
  alias FoodReserve.Menus.MenuItem

  @doc """
  Returns the list of menus for a given scope (user's restaurants).

  ## Examples

      iex> list_menus(scope)
      [%Menu{}, ...]

  """
  def list_menus(%FoodReserve.Accounts.Scope{} = scope) do
    from(m in Menu,
      join: r in assoc(m, :restaurant),
      where: r.user_id == ^scope.user.id,
      preload: [:restaurant]
    )
    |> Repo.all()
  end

  @doc """
  Gets a single menu for a given scope.

  Raises `Ecto.NoResultsError` if the Menu does not exist or doesn't belong to user.

  ## Examples

      iex> get_menu!(scope, 123)
      %Menu{}

      iex> get_menu!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_menu!(%FoodReserve.Accounts.Scope{} = scope, id) do
    from(m in Menu,
      join: r in assoc(m, :restaurant),
      where: m.id == ^id and r.user_id == ^scope.user.id,
      preload: [:restaurant]
    )
    |> Repo.one!()
  end

  @doc """
  Creates a menu for a restaurant owned by the scoped user.

  ## Examples

      iex> create_menu(scope, %{field: value})
      {:ok, %Menu{}} | {:error, %Ecto.Changeset{}}

  """
  def create_menu(%FoodReserve.Accounts.Scope{} = scope, attrs \\ %{}) do
    # Ensure the restaurant_id belongs to the user
    restaurant_id = attrs["restaurant_id"] || attrs[:restaurant_id]

    if restaurant_id do
      # Validate that the restaurant belongs to the user
      _restaurant = FoodReserve.Restaurants.get_restaurant!(scope, restaurant_id)

      %Menu{}
      |> Menu.changeset(attrs)
      |> Repo.insert()
    else
      changeset =
        %Menu{}
        |> Menu.changeset(attrs)
        |> Ecto.Changeset.add_error(:restaurant_id, "can't be blank")

      {:error, changeset}
    end
  end

  @doc """
  Updates a menu for a scoped user.

  ## Examples

      iex> update_menu(scope, menu, %{field: new_value})
      {:ok, %Menu{}} | {:error, %Ecto.Changeset{}}

  """
  def update_menu(%FoodReserve.Accounts.Scope{} = scope, %Menu{} = menu, attrs) do
    # Ensure the menu belongs to the user's restaurant
    _menu = get_menu!(scope, menu.id)

    menu
    |> Menu.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a menu for a scoped user.

  ## Examples

      iex> delete_menu(scope, menu)
      {:ok, %Menu{}} | {:error, %Ecto.Changeset{}}

  """
  def delete_menu(%FoodReserve.Accounts.Scope{} = scope, %Menu{} = menu) do
    # Ensure the menu belongs to the user's restaurant
    _menu = get_menu!(scope, menu.id)

    Repo.delete(menu)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking menu changes.

  ## Examples

      iex> change_menu(menu)
      %Ecto.Changeset{data: %Menu{}}

  """
  def change_menu(%Menu{} = menu, attrs \\ %{}) do
    Menu.changeset(menu, attrs)
  end

  alias FoodReserve.Menus.MenuItem

  @doc """
  Returns the list of menu_items for a scoped user.

  ## Examples

      iex> list_menu_items(scope)
      [%MenuItem{}, ...]

  """
  def list_menu_items(%FoodReserve.Accounts.Scope{} = scope) do
    from(mi in MenuItem,
      join: m in assoc(mi, :menu),
      join: r in assoc(m, :restaurant),
      where: r.user_id == ^scope.user.id,
      preload: [menu: {m, :restaurant}]
    )
    |> Repo.all()
  end

  @doc """
  Gets a single menu_item for a scoped user.

  Raises `Ecto.NoResultsError` if the Menu item does not exist or doesn't belong to user.

  ## Examples

      iex> get_menu_item!(scope, 123)
      %MenuItem{}

      iex> get_menu_item!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_menu_item!(%FoodReserve.Accounts.Scope{} = scope, id) do
    from(mi in MenuItem,
      join: m in assoc(mi, :menu),
      join: r in assoc(m, :restaurant),
      where: mi.id == ^id and r.user_id == ^scope.user.id,
      preload: [menu: {m, :restaurant}]
    )
    |> Repo.one!()
  end

  @doc """
  Creates a menu_item for a scoped user.

  ## Examples

      iex> create_menu_item(scope, %{field: value})
      {:ok, %MenuItem{}} | {:error, %Ecto.Changeset{}}

  """
  def create_menu_item(%FoodReserve.Accounts.Scope{} = scope, attrs \\ %{}) do
    # Ensure the menu belongs to the user's restaurant
    menu_id = attrs["menu_id"] || attrs[:menu_id]

    if menu_id do
      _menu = get_menu!(scope, menu_id)

      %MenuItem{}
      |> MenuItem.changeset(attrs)
      |> Repo.insert()
    else
      changeset =
        %MenuItem{}
        |> MenuItem.changeset(attrs)
        |> Ecto.Changeset.add_error(:menu_id, "can't be blank")

      {:error, changeset}
    end
  end

  @doc """
  Updates a menu_item for a scoped user.

  ## Examples

      iex> update_menu_item(scope, menu_item, %{field: new_value})
      {:ok, %MenuItem{}} | {:error, %Ecto.Changeset{}}

  """
  def update_menu_item(%FoodReserve.Accounts.Scope{} = scope, %MenuItem{} = menu_item, attrs) do
    # Ensure the menu item belongs to the user's restaurant
    _menu_item = get_menu_item!(scope, menu_item.id)

    menu_item
    |> MenuItem.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a menu_item for a scoped user.

  ## Examples

      iex> delete_menu_item(scope, menu_item)
      {:ok, %MenuItem{}} | {:error, %Ecto.Changeset{}}

  """
  def delete_menu_item(%FoodReserve.Accounts.Scope{} = scope, %MenuItem{} = menu_item) do
    # Ensure the menu item belongs to the user's restaurant
    _menu_item = get_menu_item!(scope, menu_item.id)

    Repo.delete(menu_item)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking menu_item changes.

  ## Examples

      iex> change_menu_item(menu_item)
      %Ecto.Changeset{data: %MenuItem{}}

  """
  def change_menu_item(%MenuItem{} = menu_item, attrs \\ %{}) do
    MenuItem.changeset(menu_item, attrs)
  end

  @doc """
  Returns the list of menu items for a specific restaurant.

  ## Examples

      iex> list_menu_items_by_restaurant(restaurant_id)
      [%MenuItem{}, ...]
  """
  def list_menu_items_by_restaurant(restaurant_id) do
    from(mi in MenuItem,
      join: m in assoc(mi, :menu),
      where: m.restaurant_id == ^restaurant_id,
      where: mi.available == true,
      order_by: [mi.category, mi.name],
      preload: [:menu]
    )
    |> Repo.all()
  end

  @doc """
  Returns the list of menu items for a restaurant owned by the user (with scope).

  ## Examples

      iex> list_menu_items_by_restaurant_scoped(scope, restaurant_id)
      [%MenuItem{}, ...]
  """
  def list_menu_items_by_restaurant_scoped(%FoodReserve.Accounts.Scope{} = scope, restaurant_id) do
    from(mi in MenuItem,
      join: m in assoc(mi, :menu),
      join: r in assoc(m, :restaurant),
      where: r.id == ^restaurant_id and r.user_id == ^scope.user.id,
      order_by: [asc: mi.inserted_at],
      preload: [menu: [:restaurant]]
    )
    |> Repo.all()
  end

  @doc """
  Returns menu items for a restaurant, with option to filter only available items.

  ## Examples

      iex> list_menu_items_for_restaurant(restaurant_id, true)
      [%MenuItem{}, ...] # only available items

      iex> list_menu_items_for_restaurant(restaurant_id)
      [%MenuItem{}, ...] # all items
  """
  def list_menu_items_for_restaurant(restaurant_id, only_available \\ false) do
    query =
      from(mi in MenuItem,
        join: m in assoc(mi, :menu),
        where: m.restaurant_id == ^restaurant_id,
        order_by: [asc: mi.category, asc: mi.name]
      )

    query =
      if only_available do
        from([mi] in query, where: mi.available == true)
      else
        query
      end

    Repo.all(query)
  end

  @doc """
  Gets a menu by restaurant ID.

  ## Examples

      iex> get_menu_by_restaurant(restaurant_id)
      %Menu{}

      iex> get_menu_by_restaurant(invalid_id)
      nil
  """
  def get_menu_by_restaurant(restaurant_id) do
    Repo.get_by(Menu, restaurant_id: restaurant_id)
  end
end
