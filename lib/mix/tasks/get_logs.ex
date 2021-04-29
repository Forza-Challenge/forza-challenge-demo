defmodule Mix.Tasks.GetLogs do
  use Mix.Task

  def run(params) do
    limit = if params == [], do: 25, else: List.first(params) |> String.to_integer()

    0 = Mix.shell().cmd("aws --profile forza-challenge-containers logs get-log-events \
      --log-group-name FCDemo \
      --log-stream-name forza-challenge-demo \
      --limit #{limit}")
  end
end
