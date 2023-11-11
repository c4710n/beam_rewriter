defmodule BeamRewriter do
  @moduledoc """
  Documentation for `BeamRewriter`.

  ## Related data structures

  * chunks - `[{name, data}, ...]`
  * named_rules - `%{ name => rules, ...}`
  * rules - `[%Rule{}, ...]`
  * specs - `[{name, data, rules}, ...]`

  """

  alias __MODULE__.BadRun
  alias __MODULE__.Rule

  @doc """
  Processes the BEAM file.
  """
  def process(file, named_rules) when is_map(named_rules) do
    file
    |> read_beam()
    |> extract_chunks()
    |> process_chunks(named_rules)
  end

  @doc """
  Processes and rewrite the BEAM file.
  """
  def rewrite!(file, named_rules) when is_binary(file) do
    file
    |> process(named_rules)
    |> write_chunks!(file)
  end

  def rewrite!([], _named_rules) do
    raise BadRun, "no files to rewrite, please check the specified filenames or wildcard"
  end

  def rewrite!(files, named_rules) when is_list(files) do
    for file <- files do
      file
      |> process(named_rules)
      |> write_chunks!(file)
    end
  end

  defp read_beam(file) do
    bytes = File.read!(file)

    case bytes do
      <<"FOR1", size::integer-size(32), "BEAM", chunks::bytes>> ->
        {size, read_chunks(chunks, [])}

      _ ->
        raise BadRun, "invalid BEAM file - #{file}"
    end
  end

  defp read_chunks(<<n, a, m, e, size::integer-size(32), tail::bytes>>, acc) do
    # align each chunk on even 4 bytes
    chunk_size_in_bytes = align_by_four(size)
    <<data::bytes-size(^chunk_size_in_bytes), rest::bytes>> = tail
    read_chunks(rest, [{[n, a, m, e], size, data} | acc])
  end

  defp read_chunks(<<>>, acc) do
    Enum.reverse(acc)
  end

  defp align_by_four(n) do
    (n + 3)
    |> div(4)
    |> Kernel.*(4)
  end

  defp extract_chunks({_size, chunks}) do
    Enum.map(chunks, fn {name, _size, data} -> {name, data} end)
  end

  defp process_chunks(chunks, named_rules) do
    chunks
    |> to_specs(named_rules)
    |> apply_specs()
  end

  defp to_specs(chunks, named_rules) do
    Enum.map(chunks, fn {name, data} ->
      rules = Map.get(named_rules, name, [])
      {name, data, rules}
    end)
  end

  defp apply_specs(specs) do
    specs
    |> Enum.reduce([], fn spec, acc ->
      case apply_spec(spec) do
        {_name, nil} -> acc
        {_name, _data} = chunk -> [chunk | acc]
      end
    end)
    |> Enum.reverse()
  end

  defp apply_spec({name, data, rules}) do
    data =
      Enum.reduce_while(rules, data, fn
        %Rule{action: :substitute, args: [pattern, replacement]}, acc ->
          acc = :binary.replace(acc, pattern, replacement, [:global])
          {:cont, acc}

        %Rule{action: :delete}, _acc ->
          {:halt, nil}
      end)

    {name, data}
  end

  defp write_chunks!(chunks, file) do
    {:ok, binary} = :beam_lib.build_module(chunks)
    File.write!(file, binary)
  end
end

defmodule BeamRewriter.BadRun do
  defexception [:message]
end
