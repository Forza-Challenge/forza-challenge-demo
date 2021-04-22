defmodule FCDemoWeb.Router do
  use FCDemoWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", FCDemoWeb do
    pipe_through :api
  end

  scope "/api/v1", ForzaChallengeWeb do
    pipe_through :api

    resources "/users", UserController, only: [:create]

    resources "/users/:user_id/competitions", CompetitionController, only: [:index]

    post "/users/:user_id/competitions/:competition_id", CompetitionController, :create_user_competiton
  end
end
