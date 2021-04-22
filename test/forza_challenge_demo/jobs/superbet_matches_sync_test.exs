defmodule FCDemo.SuperbetMatchesSyncTest do
  use FCDemo.DataCase, async: true

  import Ecto.Query, only: [from: 2]

  alias FCDemo.SuperbetMatchesSync

  alias FCDemo.SuperbetMatch
  alias FCDemo.Repo

  test "can sync matches via REAL API CALL" do
    :ok = SuperbetMatchesSync.perform()
    now = DateTime.utc_now()

    matches = Repo.all(from sm in SuperbetMatch, where: sm.starts_at >= ^now)

    assert Enum.count(matches) >= 10
  end
end
