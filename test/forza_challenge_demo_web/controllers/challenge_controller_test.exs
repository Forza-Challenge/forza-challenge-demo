defmodule FCDemoWeb.ChallengeControllerTest do
  use FCDemoWeb.ConnCase, acync: true

  alias FCDemo.SuperbetMatchesSync

  test "can return active challenges for use", %{conn: conn} do
    # populate matches via REAL API CALL
    :ok = SuperbetMatchesSync.perform()

    %{"user_id" => user_id} =
      conn
      |> post(Routes.user_path(conn, :create), %{"device_id" => Ecto.UUID.generate()})
      |> json_response(200)

    %{"active_challenges" => [challenge]} =
      conn
      |> get(Routes.challenge_path(conn, :index, user_id))
      |> json_response(200)

    assert byte_size(challenge["id"]) > 0
    assert Enum.count(challenge["matches"]) == 10

    assert %{
             "away_team_name" => _,
             "away_team_odds" => _,
             "draw_odds" => _,
             "home_team_name" => _,
             "home_team_odds" => _,
             "id" => _,
             "starts_at" => _,
             "tournament_name" => _
           } = List.first(challenge["matches"])
  end

  test "will return null is user have no active challenges", %{conn: conn} do
    %{"active_challenges" => challenges} =
      conn
      |> get(Routes.challenge_path(conn, :index, Ecto.UUID.generate()))
      |> json_response(200)

    assert is_nil(challenges)
  end
end
