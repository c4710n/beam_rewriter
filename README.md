# beam_rewriter

Rewrite BEAM files with ease.

## Usage

### Syntax

```
beam_rewriter <wildcard> \
  --substitute-chunk <chunk name> <pattern> <replacement> \
  --delete-chunk <chunk name>
```

### An example

```console
$ beam_rewriter ./parser.beam ./run.beam \
  --delete-chunk Dbgi \

$ beam_rewriter "**/*.beam" \
  --substitute-chunk Line "/nix/store" "/nix-store" \
  --delete-chunk CInf \
  --delete-chunk Dbgi \
```

> In pratice, you shouldn't delete arbitrary chunks. Here is just a demonstration of how to use this program.

## References

- [6.2. The BEAM File Format of The Erlang Runtime System](https://blog.stenmans.org/theBeamBook/#BEAM_files)

## License

MIT

```

```
