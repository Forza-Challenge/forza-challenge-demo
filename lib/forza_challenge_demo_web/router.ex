defmodule FCDemoWeb.Router do
  use FCDemoWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", FCDemoWeb do
    pipe_through :api
  end

  scope "/api/v1", FCDemoWeb do
    pipe_through :api

    resources "/users", UserController, only: [:create]

    resources "/users/:user_id/challenges", ChallengeController, only: [:index]

    post "/users/:user_id/challenges/:challenge_id", ChallengeController, :accept_user_predictions
  end

  scope "/status", FCDemoWeb do
    get "/health", StatusController, :health
  end
end
