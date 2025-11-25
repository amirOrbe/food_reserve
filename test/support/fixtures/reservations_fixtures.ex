defmodule FoodReserve.ReservationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `FoodReserve.Reservations` context.
  """

  @doc """
  Generate a reservation.
  """
  def reservation_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        customer_email: "some customer_email",
        customer_name: "some customer_name",
        customer_phone: "some customer_phone",
        party_size: 42,
        reservation_date: ~D[2025-11-24],
        reservation_time: ~T[14:00:00],
        special_requests: "some special_requests",
        status: "some status"
      })

    {:ok, reservation} = FoodReserve.Reservations.create_reservation(scope, attrs)
    reservation
  end
end
