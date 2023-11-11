defmodule BeamRewriterTest do
  use ExUnit.Case
  alias BeamRewriter.Rule
  doctest BeamRewriter

  @example_beam_file Path.expand("./example-beam-files/elixir_parser.beam", __DIR__)
  @example_beam_chunk_names @example_beam_file
                            |> BeamHelper.read()
                            |> BeamHelper.extract_names()

  describe "process/2" do
    test "remains all the chunks when no rules is specified" do
      expected_chunk_names = @example_beam_chunk_names

      chunk_names =
        BeamRewriter.process(@example_beam_file, %{})
        |> Enum.map(fn {name, _data} -> name end)

      assert chunk_names == expected_chunk_names
    end

    test "remains the original order of chunks after a chunk is substituted" do
      expected_chunk_names = @example_beam_chunk_names

      chunk_names =
        BeamRewriter.process(@example_beam_file, %{
          ~c"Line" => [%Rule{action: :substitute, args: ["/nix/store", "/nix-store"]}]
        })
        |> Enum.map(fn {name, _data} -> name end)

      assert chunk_names == expected_chunk_names
    end

    test "substitutes pattern with replacement" do
      chunk_data =
        @example_beam_file
        |> BeamHelper.read()
        |> BeamHelper.extract_chunk_data_by_name(~c"Line")

      assert {_, _} = :binary.match(chunk_data, <<"/nix/store">>)

      substituted_chunk_data =
        BeamRewriter.process(@example_beam_file, %{
          ~c"Line" => [%Rule{action: :substitute, args: ["/nix/store", "/nix-store"]}]
        })
        |> BeamHelper.extract_chunk_data_by_name(~c"Line")

      assert :nomatch = :binary.match(substituted_chunk_data, <<"/nix/store">>)
      assert {_, _} = :binary.match(substituted_chunk_data, <<"/nix-store">>)
    end

    test "remains the original order of chunks after a chunk is deleted" do
      expected_chunk_names = @example_beam_chunk_names -- [~c"Attr"]

      chunk_names =
        BeamRewriter.process(@example_beam_file, %{
          ~c"Attr" => [%Rule{action: :delete}]
        })
        |> Enum.map(fn {name, _data} -> name end)

      assert chunk_names == expected_chunk_names
    end
  end
end
