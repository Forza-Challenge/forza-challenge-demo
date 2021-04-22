defmodule FCDemo.Repo.Migrations.CreateSuperbetMatches do
  use Ecto.Migration

  def change do
    create table("superbet_matches", primary_key: false) do
      add :id, :id, primary_key: true
      add :name, :string
      add :starts_at, :utc_datetime
      add :betradar_id, :string, null: false
      add :tournament_name, :string
      add :home_team_odds, :float, null: false
      add :draw_odds, :float, null: false
      add :away_team_odds, :float, null: false

      add :home_team_name, :string, null: false
      add :away_team_name, :string, null: false

      timestamps()
    end
  end
end
