defmodule ChapterTen.SimpleRegiustry do
  use GenServer
  @self __MODULE__

  @impl true
  def init(_) do
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

    updated_storage = case result do
      :ok -> Map.put(storage, name, pid)
      :error -> storage
    end

    {:reply, result, updated_storage}
  end

  @impl true
  def handle_call({:whereis, name}, _from, storage) do
    pid = Map.get(storage, name)

    {:reply, pid, storage}
  end

end
