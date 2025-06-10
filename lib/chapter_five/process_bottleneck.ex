defmodule ChapterFive.ProcessBottleneck do
  def start do
    spawn(fn -> loop() end)
  end

  def send_msg(server, message) do
    send(server, {self(), message})

    receive do
      {:response, response} -> response
    end
  end

  def loop do
    receive do
      {caller, msg} ->
        Process.sleep(1000)
        send(caller, {:response, msg})
    end

    loop()
  end

  def spawn_concurrent(server) do
    Enum.each(1..5, fn i ->
      spawn(fn ->
        IO.puts("Sending msg ##{i}")
        response = ChapterFive.ProcessBottleneck.send_msg(server, i)
        IO.puts("Response #{response}")
      end)
    end)
  end
end
