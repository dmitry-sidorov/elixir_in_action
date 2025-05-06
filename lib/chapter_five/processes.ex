defmodule ChapterFive.Processes do
  def run_query(query) do
    Process.sleep(2000)
    "#{query} result"
  end

  def async_query(query) do
    caller = self()
    spawn(fn -> send(caller, {:query_result, run_query(query)}) end)
  end

  def spawn_many() do
    Enum.each(1..5, &async_query("query #{&1}"))
  end

  def read_postbox() do
    Enum.map(1..5, fn _ -> get_result().() end)
  end

  def get_result do
    fn ->
      receive do
        {:query_result, result} -> result
      end
    end
  end
end
