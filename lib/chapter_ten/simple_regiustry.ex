defmodule ChapterTen.SimpleRegiustry do
  use GenServer
  @self __MODULE__

  @impl true
  def init(_) do
    Process.flag(:trap_exit, true)
    {:ok, %{}}
  end

  def start_link do
    GenServer.start_link(@self, [], name: @self)
  end

  def register(name, pid) do
    GenServer.call(@self, {:register, name, pid})
  end

  def whereis(name) do
    GenServer.call(@self, {:whereis, name})
  end

  @impl true
  def handle_call({:register, name, pid}, _from, storage) do
    result = case Map.fetch(storage, name) do
      {:ok, _} -> :error
      :error -> :ok
    end

    case result do
      :ok ->
        Process.link(pid)
        {:reply, result, Map.put(storage, name, pid)}

      :error ->
        {:reply, result, storage}
    end
  end

  @impl true
  def handle_call({:whereis, name}, _from, storage) do
    pid = Map.get(storage, name)

    {:reply, pid, storage}
  end

  def handle_info({{:EXIT, pid, _reason}, storage}) do
    {:noreply, unregister_process(storage, pid)}
  end

  defp unregister_process(storage, unregistered_pid) do
    storage
    |> Enum.filter(fn {_key, process_pid} -> process_pid != unregistered_pid end)
    |> Enum.into(%{})
  end
end
