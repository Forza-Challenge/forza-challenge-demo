defmodule FCDemoWeb.StatusController do
  use FCDemoWeb, :controller

  def health(conn, _params) do
    json(conn, %{status: "ok"})
  end
end
