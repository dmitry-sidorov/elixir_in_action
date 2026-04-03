defmodule ChapterTen.SimpleRegistryEts do
  use GenServer
  @self __MODULE__

  @impl true
  def init(_) do
    Process.flag(:trap_exit, true)
    storage_ref = :ets.new(:storage, [:public])

    {:ok, storage_ref}
  end

  def start_link do
    GenServer.start_link(@self, [], name: @self)
  end

  def register(name) do
    GenServer.call(@self, {:register, name, self()})
  end

  def whereis(name) do
    GenServer.call(@self, {:whereis, name})
  end

  @impl true
  def handle_call({:register, name, pid}, _from, storage_ref) do
    result = case :ets.insert_new(storage_ref, {name, pid}) do
      true ->
        Process.link(pid)
        :ok
      false ->
        :error
    end

    {:reply, result, storage_ref}
  end

  @impl true
  def handle_call({:whereis, name}, _from, storage_ref) do
    pid = case :ets.lookup(storage_ref, name) do
      [{^name, pid}] -> pid
      [] -> nil
    end

    {:reply, pid, storage_ref}
  end

  @impl true
  def handle_info({:EXIT, pid, _reason}, storage_ref) do
    {:noreply, unregister_process(storage_ref, pid)}
  end

  defp unregister_process(storage_ref, unregistered_pid) do
    :ets.match_delete(storage_ref, {:_, unregistered_pid})

    storage_ref
  end
end
