defmodule FCDemoWeb.CompetitionController do
  use FCDemoWeb, :controller

  alias FCDemo.Cache
  alias FCDemo.Matches

  def index(conn, %{"user_id" => user_id}) do
    with {:ok, user_id} <- validate_trimid(user_id) do
      case Cache.get(user_id) do
        nil ->
          json(conn, %{active_challenges: nil})

        {challenge_id, match_ids} ->
          json(conn, %{active_challenges: [%{id: challenge_id, mathes: get_challenge_matches(match_ids)}]})
      end
    end
  end

  defp validate_trimid(id) do
    if is_binary(id) and String.trim(id) != "", do: {:ok, String.trim(id)}, else: {:error, :invalid}
  end

  defp get_challenge_matches(match_ids) do
    Matches.get_matches_by_ids(match_ids)
    |> Enum.map(&Map.drop(&1, [:betradar_id, :name, :inserted_at, :updated_at]))
  end
end
