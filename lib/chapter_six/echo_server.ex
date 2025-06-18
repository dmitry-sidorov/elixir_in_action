defmodule ChapterSix.EchoServer do
  use GenServer

  @impl GenServer
  def handle_call(request, state) do
    {:reply, request, state}
  end
end
