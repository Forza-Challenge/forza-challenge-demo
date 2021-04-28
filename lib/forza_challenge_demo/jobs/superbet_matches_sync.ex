defmodule FCDemo.SuperbetMatchesSync do
  @moduledoc """
  Periodic job: Superbet matches api sync
  """

  require Logger

  alias FCDemo.HttpClient
  alias FCDemo.DataSource
  alias FCDemo.Matches

  @weeks_2 :timer.hours(24 * 7 * 2)

  @match_types %{
    _id: :integer,
    mn: :string,
    utcDate: :utc_datetime,
    bri: :string,
    tn2: :string,
    odds: {:array, :map}
  }

  @home_team_odds_oi 2
  @draw_odds_oi 3
  @away_team_odds_oi 4

  def perform(opts \\ []) do
    http_client = Keyword.get(opts, :http_client, HttpClient)

    now = DateTime.utc_now()
    req_url = get_url(now, DateTime.add(now, @weeks_2, :millisecond))

    with {:ok, json_body} <- http_client.get_json(req_url),
         {:ok, data} <- get_data(json_body) do
      {upserted, invalid} =
        Enum.reduce(data, {0, 0}, fn match_data, {upserted_cnt, invalid_cnt} ->
          case maybe_upsert_match(match_data) do
            {:ok, _} ->
              {upserted_cnt + 1, invalid_cnt}

            {:error, reason} ->
              Logger.error("Superbet matches sync data processing error: #{inspect(reason)}")
              {upserted_cnt, invalid_cnt + 1}
          end
        end)

      Logger.info("Superbet matches sync finished: upserted #{upserted}, invalid #{invalid}")

      {:ok, opts}
    else
      {:error, reason} -> Logger.error("Superbet matches sync failed: #{inspect(reason)}")
    end
  end

  defp get_url(start_date, end_date) do
    start_date = DateTime.to_iso8601(DateTime.truncate(start_date, :second))
    end_date = DateTime.to_iso8601(DateTime.truncate(end_date, :second))

    "https://offer-1.betting.superbet.pl/offer/getOfferByDate/?preselected=1&offerState=prematch&sportId=5" <>
      "&startDate=#{start_date}&endDate=#{end_date}"
  end

  defp get_data(%{"error" => false, "data" => data}) when is_list(data) and data != [], do: {:ok, data}

  defp get_data(%{"error" => true, "notice" => reason}), do: {:error, reason}

  defp get_data(resp), do: {:error, {"unexprected response", resp}}

  defp maybe_upsert_match(match_data) when is_map(match_data) do
    case DataSource.validate_cast(match_data, @match_types, required: [:_id]) do
      {:ok, %{bri: bri, odds: odds} = match} when is_binary(bri) and is_list(odds) and odds != [] ->
        upsert_betradar_match(match)

      {:ok, _} ->
        {:ok, :noop}

      {:error, errors} ->
        {:error, {"invalid match", Map.get(match_data, "_id", "invalid id"), errors}}
    end
  end

  defp upsert_betradar_match(match) do
    [home_team_name, away_team_name] = String.split(match.mn, "·")

    params = %{
      id: match._id,
      name: match.mn,
      starts_at: match.utcDate,
      betradar_id: match.bri,
      tournament_name: match.tn2,
      home_team_odds: find_odds_by_oi(match.odds, @home_team_odds_oi),
      draw_odds: find_odds_by_oi(match.odds, @draw_odds_oi),
      away_team_odds: find_odds_by_oi(match.odds, @away_team_odds_oi),
      home_team_name: String.trim(home_team_name),
      away_team_name: String.trim(away_team_name)
    }

    Matches.upsert_superebet_match(params)
  end

  # TODO: microoptimization can be applied here to iterate odds only once
  defp find_odds_by_oi(odds, oi) when is_list(odds) do
    odds
    |> Enum.find(&(Map.get(&1, "oi") == oi))
    |> Map.get("ov")
  end
end
