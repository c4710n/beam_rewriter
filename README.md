# beam_rewriter

Rewrite BEAM files with ease.

## Usage

### Syntax

```
beam_rewriter <wildcard> \
  --substitute-chunk <chunk name> <pattern> <replacement> \
  --remove-chunk <chunk name>
```

### An example

```console
$ beam_rewriter "**/*.wildcard" \
  --substitute-chunk Line "lib/src/elixir" "lib/elixir" \
  --remove-chunk CInf \
  --remove-chunk Dbgi \
```

> In pratice, you shouldn't remove arbitrary chunks. Here is just a demonstration of how to use this program.

Above command:

1. removes `CInf` chunk
2. removes `Dbgi` chunk
3. substitutes `lib/src/elixir` with `lib/elixir` for `Line` chunk

## References

- [6.2. The BEAM File Format of The Erlang Runtime System](https://blog.stenmans.org/theBeamBook/#BEAM_files)

## License

MIT

```

```
