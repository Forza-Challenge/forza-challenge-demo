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

  test "will accept user predictions on active challenge", %{conn: conn} do
    # populate matches via REAL API CALL
    :ok = SuperbetMatchesSync.perform()

    %{"user_id" => user_id} =
      conn
      |> post(Routes.user_path(conn, :create), %{"device_id" => Ecto.UUID.generate()})
      |> json_response(200)

    %{"active_challenges" => [%{"id" => challenge_id, "matches" => challenge_matches}]} =
      conn
      |> get(Routes.challenge_path(conn, :index, user_id))
      |> json_response(200)

    predictions =
      Enum.map(challenge_matches, fn %{"id" => match_id} ->
        %{match_id: match_id, prediction: Enum.random(["home", "draw", "away"])}
      end)

    conn =
      conn
      |> post(Routes.challenge_path(conn, :accept_user_predictions, user_id, challenge_id), %{
        "predictions" => predictions
      })

    refute conn.halted
    assert conn.status == 204
  end

  # TODO: there is more complex error cases that can be tested
  test "if prediction format is incorrect return 400 error", %{conn: conn} do
    %{"error" => error} =
      conn
      |> post(Routes.challenge_path(conn, :accept_user_predictions, Ecto.UUID.generate(), Ecto.UUID.generate()), %{
        "predictions" => nil
      })
      |> json_response(422)

    assert error == "invalid predictions array"
  end

  test "if no challenge found returns 404 eror", %{conn: conn} do
    %{"error" => error} =
      conn
      |> post(Routes.challenge_path(conn, :accept_user_predictions, Ecto.UUID.generate(), Ecto.UUID.generate()), %{
        "predictions" => Enum.map(1..10, &%{"match_id" => &1, "prediction" => "draw"})
      })
      |> json_response(404)

    assert error == "no active challenges found"
  end
end
