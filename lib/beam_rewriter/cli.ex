defmodule BeamRewriter.CLI do
  @moduledoc """
  The command line interface of `BeamRewriter`.
  """

  alias BeamRewriter.Rule
  alias BeamRewriter.BadRun
  alias __MODULE__.BadArgv

  def main(argv \\ System.argv()) do
    {raw_rules, raw_files} = do_parse(argv, {nil, [], [], []})

    files =
      raw_files
      |> Enum.map(&Path.expand(&1, File.cwd!()))
      |> Enum.map(&Path.wildcard/1)
      |> List.flatten()

    named_rules =
      raw_rules
      |> Enum.map(&to_rule/1)
      |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))

    try do
      BeamRewriter.rewrite!(files, named_rules)
      System.stop(0)
    rescue
      error in [BadRun, BadArgv] ->
        abort(error)
    end
  end

  # TODO: provide usage instead of a link to users.
  defp abort(error) do
    IO.write(:stderr, """
    #{error.message}

    Visit https://github.com/c4710n/beam_rewriter for more details.
    """)

    System.stop(1)
  end

  defp to_rule({:substitute = action, [chunk_name | args]}),
    do: {to_charlist(chunk_name), %Rule{action: action, args: args}}

  defp to_rule({:delete = action, [chunk_name]}),
    do: {to_charlist(chunk_name), %Rule{action: action, args: []}}

  defp do_parse(
         ["--substitute-chunk" | rest],
         {nil = _ctx, ctx_argv, raw_rules, raw_files}
       ) do
    do_parse(rest, {:substitute, ctx_argv, raw_rules, raw_files})
  end

  defp do_parse(
         ["--delete-chunk" | rest],
         {nil = _ctx, ctx_argv, raw_rules, raw_files}
       ) do
    do_parse(rest, {:delete, ctx_argv, raw_rules, raw_files})
  end

  defp do_parse(
         rest,
         {:substitute = _ctx, [_, _, _] = ctx_argv, raw_rules, raw_files}
       ) do
    do_parse(rest, {nil, [], [{:substitute, Enum.reverse(ctx_argv)} | raw_rules], raw_files})
  end

  defp do_parse(
         rest,
         {:delete = _ctx, [_] = ctx_argv, raw_rules, raw_files}
       ) do
    do_parse(rest, {nil, [], [{:delete, Enum.reverse(ctx_argv)} | raw_rules], raw_files})
  end

  defp do_parse(
         [arg | rest],
         {ctx, ctx_argv, raw_rules, raw_files}
       )
       when not is_nil(ctx) do
    do_parse(rest, {ctx, [check_arg!(arg) | ctx_argv], raw_rules, raw_files})
  end

  defp do_parse(
         [arg | rest],
         {ctx, ctx_argv, raw_rules, raw_files}
       )
       when is_nil(ctx) do
    do_parse(rest, {ctx, ctx_argv, raw_rules, [check_arg!(arg) | raw_files]})
  end

  defp do_parse([], {_ctx, _ctx_argv, raw_rules, raw_files}) do
    {
      Enum.reverse(raw_rules),
      Enum.reverse(raw_files)
    }
  end

  defp check_arg!("--" <> _ = arg) do
    raise BadArgv, "unexpected argument - #{arg}"
  end

  defp check_arg!(arg) do
    arg
  end
end

defmodule BeamRewriter.CLI.BadArgv do
  defexception [:message]
end
