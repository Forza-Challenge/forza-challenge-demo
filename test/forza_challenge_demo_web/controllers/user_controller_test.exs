defmodule FCDemoWeb.UserControllerTest do
  use FCDemoWeb.ConnCase, async: true

  test "can create new user", %{conn: conn} do
    %{"user_id" => user_id} =
      conn
      |> post(Routes.user_path(conn, :create), %{"device_id" => Ecto.UUID.generate()})
      |> json_response(200)

    assert byte_size(user_id) > 0
  end

  test "return 400 for invalid device_id", %{conn: conn} do
    %{"error" => error} =
      conn
      |> post(Routes.user_path(conn, :create), %{})
      |> json_response(400)

    assert error == "invalid device_id"
  end
end
