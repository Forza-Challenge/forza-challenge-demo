defmodule FCDemo.ChallengesTest do
  use FCDemo.DataCase, async: true

  import Ecto.Query, only: [from: 2]

  alias FCDemo.Challenges
  alias FCDemo.SuperbetMatchesSync

  alias FCDemo.SuperbetMatch
  alias FCDemo.Repo

  test "can create new challenge with 10 random matches" do
    now = DateTime.utc_now()

    # populate matches via REAL API CALL
    :ok = SuperbetMatchesSync.perform()

    {challenge_id, challenge_matches} = Challenges.generate_random_challenge()

    assert is_binary(challenge_id)
    assert Enum.count(challenge_matches) == 10

    {challenge_id_2, challenge_matches_2} = Challenges.generate_random_challenge()

    assert challenge_id != challenge_id_2
    assert challenge_matches != challenge_matches_2

    matches = Repo.all(from sm in SuperbetMatch, where: sm.id in ^challenge_matches, select: sm.starts_at)
    assert Enum.all?(matches, &(DateTime.compare(&1, now) == :gt))
  end
end
