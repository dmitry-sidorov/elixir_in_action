defmodule ChapterSix.TodoListGenServer do
  alias ChapterFive.TodoList
  use GenServer

  def start do
    GenServer.start(ChapterSix.TodoListGenServer, nil)
  end

  @impl GenServer
  def init(_state) do
    {:ok, TodoList.new()}
  end

  @impl GenServer
  def handle_call({:entries, date}, _from, todo_list) do
    entries = TodoList.entries(todo_list, date)

    {:reply, {:ok, entries}, todo_list}
  end

  @impl GenServer
  def handle_call({:add_entry, entry}, _from, todo_list) do
    updated_todo_list = TodoList.add_entry(todo_list, entry)

    {:reply, {:ok, updated_todo_list}, updated_todo_list}
  end

  @impl GenServer
  def handle_call({:update_entry, entry_id, updater_fn}, _from, todo_list) do
    updated_todo_list = TodoList.update_entry(todo_list, entry_id, updater_fn)

    {:reply, {:ok, updated_todo_list}, updated_todo_list}
  end

  @impl GenServer
  def handle_call({:delete_entry, entry_id}, _from, todo_list) do
    updated_todo_list = TodoList.delete_entry(todo_list, entry_id)

    {:reply, {:ok, updated_todo_list}, updated_todo_list}
  end

  def get_mock_data do
    ~D[2018-12-19]
  end

  def get_mock_entry do
    [
      %{date: get_mock_data(), title: "Dentist"},
      %{date: get_mock_data(), title: "Movies"},
      %{date: get_mock_data(), title: "Shopping"},
      %{date: get_mock_data(), title: "Sleeping"},
      %{date: get_mock_data(), title: "Dinner"},
    ] |> Enum.random()
  end
end
