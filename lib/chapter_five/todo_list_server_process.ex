defmodule ChapterFive.AbstractServerProcess do
  alias ChapterFive.{AbstractServerProcess, TodoList, ServerProcess}

  def start do
    ServerProcess.start(AbstractServerProcess)
  end

  # callback
  def init do
    TodoList.new()
  end

  # callback
  def handle_call({:entries, date}, todo_list) do
    entries = TodoList.entries(todo_list, date)

    {{:ok, entries}, entries}
  end

  # callback
  def handle_call({:add_entry, entry}, todo_list) do
    {:ok, TodoList.add_entry(todo_list, entry)}
  end

  # callback
  def handle_call({:update_entry, entry_id, updater_fn}, todo_list) do
    {:ok, TodoList.update_entry(todo_list, entry_id, updater_fn)}
  end

  # callback
  def handle_call({:delete_entry, entry_id}, todo_list) do
    {:ok, TodoList.delete_entry(todo_list, entry_id)}
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
