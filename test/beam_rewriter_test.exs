defmodule BeamRewriterTest do
  use ExUnit.Case
  doctest BeamRewriter

  test "greets the world" do
    assert BeamRewriter.hello() == :world
  end
end
