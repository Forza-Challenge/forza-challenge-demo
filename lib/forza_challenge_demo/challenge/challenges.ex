defmodule FCDemo.Challenges do
  import Ecto.Query, only: [from: 2]

  alias FCDemo.SuperbetMatch
  alias FCDemo.Repo

  def generate_random_challenge() do
    challenge_id = Ecto.UUID.generate()
    now = DateTime.utc_now()

    challenge_matches =
      from(sm in SuperbetMatch, where: sm.starts_at >= ^now, select: sm.id, order_by: fragment("random()"), limit: 10)
      |> Repo.all()

    {challenge_id, challenge_matches}
  end
end
