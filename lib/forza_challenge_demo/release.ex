defmodule FCDemo.Release do
  @app :forza_challenge_demo

  # commands

  def migrate do
    load_app()

    for repo <- repos() do
      :ok = ensure_repo_created(repo)
      IO.puts("Running migration for #{inspect(repo)}")
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def seed do
    load_app()

    for repo <- repos() do
      IO.puts("Running seed for #{inspect(repo)}")
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &run_seeds_for(&1))
    end
  end

  # internal

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

  defp run_seeds_for(repo) do
    # Run the seed script if it exists
    seed_script = priv_path_for(repo, "seeds.exs")

    if File.exists?(seed_script) do
      IO.puts("Running seed script...")
      Code.eval_file(seed_script)
    else
      IO.puts("Seed script not found...")
    end
  end

  defp priv_path_for(repo, filename) do
    repo_underscore =
      repo
      |> Module.split()
      |> List.last()
      |> Macro.underscore()

    priv_dir = "#{:code.priv_dir(@app)}"

    Path.join([priv_dir, repo_underscore, filename])
  end
end
