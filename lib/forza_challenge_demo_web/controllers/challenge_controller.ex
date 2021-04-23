defmodule FCDemoWeb.ChallengeController do
  use FCDemoWeb, :controller

  alias FCDemo.Cache
  alias FCDemo.DataSource
  alias FCDemo.Matches

  @predictions_types %{
    match_id: :integer,
    prediction: :string
  }

  @predictions ["home", "away", "draw"]

  def index(conn, %{"user_id" => user_id}) do
    with {:ok, user_id} <- validate_trim_id(user_id) do
      case Cache.get(user_id) do
        nil ->
          json(conn, %{active_challenges: nil})

        {challenge_id, match_ids} ->
          json(conn, %{active_challenges: [%{id: challenge_id, matches: get_challenge_matches(match_ids)}]})
      end
    else
      {:error, :invalid} -> conn |> put_status(400) |> json(%{error: "invalid user_id"})
    end
  end

  def accept_user_predictions(conn, %{
        "user_id" => user_id,
        "challenge_id" => challenge_id,
        "predictions" => predictions
      }) do
    with {:ok, user_id} <- validate_trim_id(user_id),
         {:ok, challenge_id} <- validate_trim_id(challenge_id),
         {:ok, predictions} <- validate_cast_predictions(predictions),
         {:ok, :valid} <- validate_challenge_predictions(user_id, challenge_id, predictions) do
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(204, "")
    else
      {:error, :invalid} -> conn |> put_status(400) |> json(%{error: "invalid user_id or challenge_id"})
      {:error, {:invalid_predictions, error}} -> conn |> put_status(422) |> json(%{error: error})
    end
  end

  # Helpers

  defp validate_trim_id(id) do
    if is_binary(id) and String.trim(id) != "", do: {:ok, String.trim(id)}, else: {:error, :invalid}
  end

  defp get_challenge_matches(match_ids) do
    Matches.get_matches_by_ids(match_ids)
    |> Enum.map(
      &Map.take(&1, [
        :id,
        :starts_at,
        :tournament_name,
        :home_team_name,
        :away_team_name,
        :home_team_odds,
        :draw_odds,
        :away_team_odds
      ])
    )
  end

  # validate predictions
  defp validate_cast_predictions(predictions) when is_list(predictions) do
    cnt = Enum.count(predictions)

    if cnt == 10 do
      do_validate_cast_predictions(predictions, [])
    else
      {:error, {:invalid_predictions, "expected 10 predictions got #{cnt}"}}
    end
  end

  defp validate_cast_predictions(_predictions), do: {:error, {:invalid_predictions, "invalid predictions array"}}

  defp do_validate_cast_predictions([], res), do: {:ok, res}

  defp do_validate_cast_predictions([h | t], res) do
    if is_map(h) do
      case DataSource.validate_cast(h, @predictions_types) do
        {:ok, prediction} ->
          do_validate_cast_predictions(t, [prediction | res])

        {:error, errors} ->
          {:error, {:invalid_predictions, "invalid prediction '#{inspect(h)}', errors: #{inspect(errors)}"}}
      end
    else
      {:error, {:invalid_predictions, "invalid prediction format '#{inspect(h)}'"}}
    end
  end

  defp validate_challenge_predictions(user_id, challenge_id, predictions) do
    case Cache.get(user_id) do
      nil ->
        {:error, {:not_found, "no active challenges found"}}

      {chached_challenge_id, matches} ->
        if chached_challenge_id == challenge_id do
          validate_predictions_agains_challenge_matches(predictions, matches)
        else
          {:error, {:not_found, "active challenge #{challenge_id} not found"}}
        end
    end
  end

  defp validate_predictions_agains_challenge_matches([], _), do: {:ok, :valid}

  defp validate_predictions_agains_challenge_matches([h | t], challenge_matches) do
    if h.match_id in challenge_matches and h.prediction in @predictions do
      validate_predictions_agains_challenge_matches(t, challenge_matches)
    else
      {:error, {:invalid_predictions, "invalid prediction #{inspect(h)}"}}
    end
  end
end
