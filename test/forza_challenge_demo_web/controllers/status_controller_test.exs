defmodule FCDemoWeb.StatusControllerTest do
  use FCDemoWeb.ConnCase, acync: true

  test "health check", %{conn: conn} do
    %{"status" => status} =
      conn
      |> get(Routes.status_path(conn, :health))
      |> json_response(200)

    assert status == "ok"
  end
end
