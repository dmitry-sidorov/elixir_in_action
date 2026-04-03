defmodule SimpleRegistryTestEts do
  alias ChapterTen.SimpleRegistryEts
  use ExUnit.Case, async: false

  describe "SimpleRegistry" do
    setup do
      SimpleRegistryEts.start_link()
      :ok
    end

    test "should register process" do
      assert SimpleRegistryEts.register("foo") == :ok
    end

    test "registered process should be self" do
      assert SimpleRegistryEts.register("foo") == :ok
      assert SimpleRegistryEts.whereis("foo") == self()
    end

    test "should not register process twice" do
      assert SimpleRegistryEts.register("foo") == :ok
      assert SimpleRegistryEts.register("foo") == :error
    end

    test "should unregister dead process" do
      {:ok, pid} = Agent.start_link(fn -> SimpleRegistryEts.register("bar") end)
      assert SimpleRegistryEts.whereis("bar") == pid
      Agent.stop(pid)
      Process.sleep(100)
      assert SimpleRegistryEts.whereis("bar") == nil
    end
  end
end
