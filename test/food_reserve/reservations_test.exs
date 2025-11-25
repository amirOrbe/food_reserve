defmodule FoodReserve.ReservationsTest do
  use FoodReserve.DataCase

  alias FoodReserve.Reservations

  describe "reservations" do
    alias FoodReserve.Reservations.Reservation

    import FoodReserve.AccountsFixtures, only: [user_scope_fixture: 0]
    import FoodReserve.ReservationsFixtures

    @invalid_attrs %{
      status: nil,
      reservation_date: nil,
      reservation_time: nil,
      party_size: nil,
      special_requests: nil,
      customer_name: nil,
      customer_phone: nil,
      customer_email: nil
    }

    test "list_reservations/1 returns all scoped reservations" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      reservation = reservation_fixture(scope)
      other_reservation = reservation_fixture(other_scope)
      assert Reservations.list_reservations(scope) == [reservation]
      assert Reservations.list_reservations(other_scope) == [other_reservation]
    end

    test "get_reservation!/2 returns the reservation with given id" do
      scope = user_scope_fixture()
      reservation = reservation_fixture(scope)
      other_scope = user_scope_fixture()
      assert Reservations.get_reservation!(scope, reservation.id) == reservation

      assert_raise Ecto.NoResultsError, fn ->
        Reservations.get_reservation!(other_scope, reservation.id)
      end
    end

    test "create_reservation/2 with valid data creates a reservation" do
      valid_attrs = %{
        status: "some status",
        reservation_date: ~D[2025-11-24],
        reservation_time: ~T[14:00:00],
        party_size: 42,
        special_requests: "some special_requests",
        customer_name: "some customer_name",
        customer_phone: "some customer_phone",
        customer_email: "some customer_email"
      }

      scope = user_scope_fixture()

      assert {:ok, %Reservation{} = reservation} =
               Reservations.create_reservation(scope, valid_attrs)

      assert reservation.status == "some status"
      assert reservation.reservation_date == ~D[2025-11-24]
      assert reservation.reservation_time == ~T[14:00:00]
      assert reservation.party_size == 42
      assert reservation.special_requests == "some special_requests"
      assert reservation.customer_name == "some customer_name"
      assert reservation.customer_phone == "some customer_phone"
      assert reservation.customer_email == "some customer_email"
      assert reservation.user_id == scope.user.id
    end

    test "create_reservation/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Reservations.create_reservation(scope, @invalid_attrs)
    end

    test "update_reservation/3 with valid data updates the reservation" do
      scope = user_scope_fixture()
      reservation = reservation_fixture(scope)

      update_attrs = %{
        status: "some updated status",
        reservation_date: ~D[2025-11-25],
        reservation_time: ~T[15:01:01],
        party_size: 43,
        special_requests: "some updated special_requests",
        customer_name: "some updated customer_name",
        customer_phone: "some updated customer_phone",
        customer_email: "some updated customer_email"
      }

      assert {:ok, %Reservation{} = reservation} =
               Reservations.update_reservation(scope, reservation, update_attrs)

      assert reservation.status == "some updated status"
      assert reservation.reservation_date == ~D[2025-11-25]
      assert reservation.reservation_time == ~T[15:01:01]
      assert reservation.party_size == 43
      assert reservation.special_requests == "some updated special_requests"
      assert reservation.customer_name == "some updated customer_name"
      assert reservation.customer_phone == "some updated customer_phone"
      assert reservation.customer_email == "some updated customer_email"
    end

    test "update_reservation/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      reservation = reservation_fixture(scope)

      assert_raise MatchError, fn ->
        Reservations.update_reservation(other_scope, reservation, %{})
      end
    end

    test "update_reservation/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      reservation = reservation_fixture(scope)

      assert {:error, %Ecto.Changeset{}} =
               Reservations.update_reservation(scope, reservation, @invalid_attrs)

      assert reservation == Reservations.get_reservation!(scope, reservation.id)
    end

    test "delete_reservation/2 deletes the reservation" do
      scope = user_scope_fixture()
      reservation = reservation_fixture(scope)
      assert {:ok, %Reservation{}} = Reservations.delete_reservation(scope, reservation)

      assert_raise Ecto.NoResultsError, fn ->
        Reservations.get_reservation!(scope, reservation.id)
      end
    end

    test "delete_reservation/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      reservation = reservation_fixture(scope)
      assert_raise MatchError, fn -> Reservations.delete_reservation(other_scope, reservation) end
    end

    test "change_reservation/2 returns a reservation changeset" do
      scope = user_scope_fixture()
      reservation = reservation_fixture(scope)
      assert %Ecto.Changeset{} = Reservations.change_reservation(scope, reservation)
    end
  end
end
