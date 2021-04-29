defmodule Mix.Tasks.CheckHealth do
  use Mix.Task

  def run(_) do
    0 = Mix.shell().cmd("curl -sS https://demo.forza-challenge.com/status/health")
  end
end
