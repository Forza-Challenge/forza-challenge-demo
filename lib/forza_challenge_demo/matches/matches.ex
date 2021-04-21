defmodule FCDemo.Matches do
  @moduledoc """
  Matches context
  """

  alias FCDemo.SuperbetMatch

  alias FCDemo.Repo

  def upsert_superebet_match(params) when is_map(params) do
    SuperbetMatch.changeset(%SuperbetMatch{}, params)
    |> Repo.insert(conflict_target: [:id], on_conflict: {:replace_all_except, [:id]})
  end
end
