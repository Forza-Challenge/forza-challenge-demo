defmodule FCDemoWeb.UserController do
  use FCDemoWeb, :controller

  alias FCDemo.Cache
  alias FCDemo.Challenges

  def create(conn, params) do
    device_id = Map.get(params, "device_id")

    with {:ok, :valid} <- valid_id(device_id) do
      user_id = Ecto.UUID.generate()
      :ok = create_user_challenge(user_id)
      json(conn, %{user_id: user_id})
    else
      {:error, :invalid} -> conn |> put_status(400) |> json(%{error: "invalid device_id"})
    end
  end

  defp valid_id(device_id) do
    if is_binary(device_id) and String.trim(device_id) != "", do: {:ok, :valid}, else: {:error, :invalid}
  end

  defp create_user_challenge(user_id) do
    user_challenge = Challenges.generate_random_challenge()
    Cache.put(user_id, user_challenge)
  end
end
