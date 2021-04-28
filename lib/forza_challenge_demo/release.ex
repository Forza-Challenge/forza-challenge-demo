defmodule FCDemo.Release do
  @app :forza_challenge_demo

  def migrate do
    load_app()

    for repo <- repos() do
      :ok = ensure_repo_created(repo)
      IO.puts("Running migration for #{inspect(repo)}")
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end

  defp ensure_repo_created(repo) do
    case repo.__adapter__.storage_up(repo.config) do
      :ok ->
        IO.puts("Creating repo #{inspect(repo)}")
        :ok

      {:error, :already_up} ->
        IO.puts("Repo #{inspect(repo)} already up")
        :ok

      {:error, term} ->
        {:error, term}
    end
  end
end
