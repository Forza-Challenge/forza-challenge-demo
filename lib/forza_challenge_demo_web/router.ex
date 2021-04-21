defmodule FCDemoWeb.Router do
  use FCDemoWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", FCDemoWeb do
    pipe_through :api
  end
end
