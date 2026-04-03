defmodule SimpleRegistryTest do
  alias ChapterTen.SimpleRegistry
  use ExUnit.Case, async: false

  describe "SimpleRegistry" do
    setup do
      SimpleRegistry.start_link()
      :ok
    end

    test "should register process" do
      assert SimpleRegistry.register("foo") == :ok
    end

    test "registered process should be self" do
      assert SimpleRegistry.register("foo") == :ok
      assert SimpleRegistry.whereis("foo") == self()
    end

    test "should not register process twice" do
      assert SimpleRegistry.register("foo") == :ok
      assert SimpleRegistry.register("foo") == :error
    end

    test "should unregister dead process" do
      {:ok, pid} = Agent.start_link(fn -> SimpleRegistry.register("bar") end)
      assert SimpleRegistry.whereis("bar") == pid
      Agent.stop(pid)
      Process.sleep(100)
      assert SimpleRegistry.whereis("bar") == nil
    end
  end
end
