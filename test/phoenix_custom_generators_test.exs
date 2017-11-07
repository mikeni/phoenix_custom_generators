defmodule PhoenixCustomGeneratorsTest do
  use ExUnit.Case
  doctest PhoenixCustomGenerators

  test "greets the world" do
    assert PhoenixCustomGenerators.hello() == :world
  end
end
