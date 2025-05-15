defmodule ChapterFive.TodoList do
  defstruct next_id: 1, entries: %{}

  def new(entries \\ []) do
    Enum.reduce(
      entries,
      %ChapterFive.TodoList{},
      &add_entry(&2, &1)
    )
  end

  def add_entry(todo_list, entry) do
    entry = Map.put(entry, :id, todo_list.next_id)
    new_entries = Map.put(todo_list.entries, todo_list.next_id, entry)

    %ChapterFive.TodoList{todo_list | entries: new_entries, next_id: todo_list.next_id + 1}
  end

  def entries(todo_list, date) do
    todo_list.entries
    |> Map.values()
    |> Enum.filter(fn entry -> entry.date == date end)
  end

  def update_entry(todo_list, entry_id, updater_fun) do
    case Map.fetch(todo_list.entries, entry_id) do
      :error ->
        todo_list

      {:ok, old_entry} ->
        new_entry = updater_fun.(old_entry) |> IO.inspect()
        new_entries = Map.put(todo_list.entries, new_entry.id, new_entry)
        %ChapterFive.TodoList{todo_list | entries: new_entries}
    end
  end

  def delete_entry(todo_list, entry_id) do
    %ChapterFive.TodoList{todo_list | entries: Map.delete(todo_list.entries, entry_id)}
  end
end

defmodule ChapterFive.TodoServer do
  def start do
    spawn(fn -> loop(ChapterFive.TodoList.new()) end)
  end

  def get_mock_data do
    ~D[2018-12-19]
  end

  def populate_entries(todo_server) do
    [
      %{date: get_mock_data(), title: "Dentist"},
      %{date: get_mock_data(), title: "Movies"},
      %{date: get_mock_data(), title: "Shopping"},
    ] |> Enum.each(fn new_entry -> send(todo_server, {:add_entry, new_entry}) end)
  end

  def entries(todo_server, date) do
    send(todo_server, {:entries, self(), date})

    receive do
      {:todo_entries, entries} -> entries
    after
      5000 -> {:error, :timeout}
    end
  end

  def delete_entry(todo_server, entry_id) do
    send(todo_server, {:delete_entry, entry_id})
  end

  def add_entry(todo_server, new_entry) do
    send(todo_server, {:add_entry, new_entry})
  end

  def update_entry(todo_server, entry_id, updater_fn) do
    send(todo_server, {:update_entry, entry_id, updater_fn})
  end

  defp loop(todo_list) do
    new_todo_list =
      receive do
        message -> process_message(todo_list, message)
      end

    loop(new_todo_list)
  end

  defp process_message(todo_list, {:delete_entry, entry_id}) do
    ChapterFive.TodoList.delete_entry(todo_list, entry_id)
  end

  defp process_message(todo_list, {:add_entry, new_entry}) do
    ChapterFive.TodoList.add_entry(todo_list, new_entry)
  end

  defp process_message(todo_list, {:update_entry, entry_id, updater_fn}) do
    ChapterFive.TodoList.update_entry(todo_list, entry_id, updater_fn)
  end

  defp process_message(todo_list, {:entries, caller, date}) do
    send(caller, {:todo_entries, ChapterFive.TodoList.entries(todo_list, date)})
    todo_list
  end
end
