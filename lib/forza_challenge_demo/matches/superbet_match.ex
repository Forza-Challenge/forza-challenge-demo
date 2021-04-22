defmodule FCDemo.SuperbetMatch do
  @moduledoc """
  Superbet Match schema
  """

  use Ecto.Schema

  import Ecto.Changeset

  # "_id", "mi"
  @primary_key {:id, :id, autogenerate: false}

  schema "superbet_matches" do
    # "mn"
    field :name, :string
    # "utcDate"
    field :starts_at, :utc_datetime
    # "bri"
    field :betradar_id, :string
    # "tn2"
    field :tournament_name, :string
    # "odds" -> "oi" == 2 -> "ov"
    field :home_team_odds, :float
    # "odds" -> "oi" == 3 -> "ov"
    field :draw_odds, :float
    # "odds" -> "oi" == 4 -> "ov"
    field :away_team_odds, :float

    # we get this fileds from tournament_name splitting on '·'
    field :home_team_name, :string
    field :away_team_name, :string

    timestamps()
  end

  def changeset(%__MODULE__{} = superbet_match, params \\ %{}) do
    all_fields = [
      :id,
      :starts_at,
      :betradar_id,
      :tournament_name,
      :home_team_odds,
      :draw_odds,
      :away_team_odds,
      :home_team_name,
      :away_team_name
    ]

    superbet_match
    |> cast(params, all_fields)
    |> validate_required(all_fields)
    |> validate_number(:home_team_odds, greater_than_or_equal_to: 0)
    |> validate_number(:draw_odds, greater_than_or_equal_to: 0)
    |> validate_number(:away_team_odds, greater_than_or_equal_to: 0)
  end
end
