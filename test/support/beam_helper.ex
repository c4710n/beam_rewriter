defmodule BeamHelper do
  @moduledoc """
  Provide benchmarks for testing.
  """
  def read(file) do
    bytes = File.read!(file)
    <<"FOR1", size::integer-size(32), "BEAM", chunks::bytes>> = bytes
    {size, read_chunks(chunks, [])}
  end

  def extract_names({_, [{_, _, _} | _] = chunks}) do
    Enum.map(chunks, fn {name, _size, _data} -> name end)
  end

  def extract_chunk_data_by_name({_, [{_, _, _} | _] = chunks}, name) do
    {_name, _size, data} = List.keyfind(chunks, name, 0)
    data
  end

  def extract_chunk_data_by_name([{_, _} | _] = chunks, name) do
    {_name, data} = List.keyfind(chunks, name, 0)
    data
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
end
