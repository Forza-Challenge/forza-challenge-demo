defmodule FCDemo.Matches do
  @moduledoc """
  Matches context
  """

  import Ecto.Query, only: [from: 2]

  alias FCDemo.SuperbetMatch
  alias FCDemo.Repo

  def upsert_superebet_match(params) when is_map(params) do
    SuperbetMatch.changeset(%SuperbetMatch{}, params)
    |> Repo.insert(conflict_target: [:id], on_conflict: {:replace_all_except, [:id]})
  end

  def get_matches_by_ids(match_ids) when is_list(match_ids) do
    Repo.all(from sm in SuperbetMatch, where: sm.id in ^match_ids)
  end
end
