defmodule ChapterFive.ServerProcess do
  def start(callback_module) do
    spawn(fn ->
      initial_state = callback_module.init()
      loop(callback_module, initial_state)
    end)
  end

  def call(server_pid, request) do
    send(server_pid, {request, self()})

    receive do
      {:response, response} -> response
    end

  end

  def info(server_pid) do
    send(server_pid, {:info, self()})

    receive do
      {:response, response} -> response
    end

  end

  defp loop(callback_module, current_state) do
    receive do
      {:info, caller} ->
        send(caller, {:response, current_state})

        loop(callback_module, current_state)
      {request, caller} ->
        {response, new_state} = callback_module.handle_call(request, current_state)

        send(caller, {:response, response})

        loop(callback_module, new_state)
    end
  end
end

defmodule ChapterFive.KeyValueStore do
  def init do
    %{}
  end

  def handle_call({:put, key, value}, state) do
    {:ok, Map.put(state, key, value)}
  end

  def handle_call({:get, key}, state) do
    {Map.get(state, key), state}
  end
end
