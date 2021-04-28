defmodule FCDemo.GlobalJobsScheduler do
  @moduledoc """
  Global Module that can run schedulled jobs on one of the available nodes

  Params:
    enable: bool,
    immediate: bool (default = false),
    interval: integer,
    module: atom,
    state: term (default = nil),
    timeout: integer (default = 5000)
  """

  @job_function :perform

  use GenServer

  defstruct [:interval, :module, :state, :timeout]

  require Logger

  # client

  def start_link(params) when is_map(params) do
    GenServer.start_link(__MODULE__, params)
  end

  # server

  @impl true
  def init(%{enable: true, interval: interval, module: module} = params) do
    state = %__MODULE__{
      interval: interval,
      module: module,
      state: Map.get(params, :state),
      timeout: Map.get(params, :timeout, :timer.seconds(5))
    }

    case try_register_global_name({__MODULE__, module}) do
      {:ok, :registered} ->
        Logger.info("Periodic job: scheduller registered on node #{Node.self()} for #{module}")

        if Map.get(params, :immediate, true) do
          Process.send(self(), :execute_periodic_job, [])
        else
          Process.send_after(self(), :execute_periodic_job, interval)
        end

      {:error, :exists} ->
        Logger.info("Periodic job: monitoring from node #{Node.self()} for #{module}")

        Process.send_after(self(), :monitor_global_scheduler, interval)
    end

    {:ok, state}
  end

  def init(%{enable: false}), do: :ignore

  @impl true
  def handle_info(:execute_periodic_job, %__MODULE__{} = scheduler_state) do
    new_state =
      case execute_periodic_job(scheduler_state.module, scheduler_state.state, scheduler_state.timeout) do
        {:ok, state} ->
          state

        {:error, error} ->
          Logger.error("Periodic job on node #{Node.self()} for #{scheduler_state.module} error #{inspect(error)}")
          scheduler_state.state
      end

    Process.send_after(self(), :execute_periodic_job, scheduler_state.interval)

    {:noreply, %{scheduler_state | state: new_state}}
  end

  def handle_info(:monitor_global_scheduler, %__MODULE__{} = scheduler_state) do
    case try_register_global_name({__MODULE__, scheduler_state.module}) do
      {:ok, :registered} ->
        Logger.warn("Periodic job: new scheduler registered on node #{Node.self()} for #{scheduler_state.module}")

        Process.send(self(), :execute_periodic_job, [])

      {:error, :exists} ->
        Process.send_after(self(), :monitor_global_scheduler, scheduler_state.interval)
    end

    {:noreply, scheduler_state}
  end

  # helpers

  defp try_register_global_name({__MODULE__, _task_module} = global_name) do
    case :global.whereis_name(global_name) do
      :undefined ->
        case :global.register_name(global_name, self()) do
          :yes -> {:ok, :registered}
          :no -> {:error, :exists}
        end

      pid ->
        if pid != self(), do: {:error, :exists}, else: {:error, :self}
    end
  end

  defp execute_periodic_job(module, state, timeout) do
    random_node = Enum.random(Node.list([:visible, :this]))

    if random_node != Node.self() do
      :erpc.call(random_node, module, @job_function, [state], timeout)
    else
      apply(module, @job_function, [state])
    end
  end
end
