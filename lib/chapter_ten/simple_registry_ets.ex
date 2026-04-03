defmodule ChapterTen.SimpleRegistryEts do
  use GenServer
  @self __MODULE__

  @impl true
  def init(_) do
    Process.flag(:trap_exit, true)
    :ets.new(@self, [:public, :named_table, read_concurrency: true, write_concurrency: true])

    {:ok, nil}
  end

  def start_link do
    GenServer.start_link(@self, [], name: @self)
  end

  def register(name) do
    caller_pid = self()

    case :ets.insert_new(@self, {name, caller_pid}) do
      true ->
        Process.link(caller_pid)
        :ok
      false ->
        :error
    end
  end

  def whereis(name) do
    case :ets.lookup(@self, name) do
      [{^name, pid}] -> pid
      [] -> nil
    end
  end



  @impl true
  def handle_info({:EXIT, pid, _reason}, state) do
    :ets.match_delete(@self, {:_, pid})

    {:noreply, state}
  end
end
