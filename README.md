# beam_rewriter

Rewrite BEAM files with ease.

## Build

```
$ mix escript.build
```

Then, the generated escript will be placed at `escript/beam_rewriter`.

## Usage

### Syntax

```
beam_rewriter <wildcard> \
  --substitute-chunk <chunk name> <pattern> <replacement> \
  --delete-chunk <chunk name>
```

### Examples

```
# substitue string in a chunk
$ beam_rewriter ./parser.beam \
  --substitute-chunk Line "/nix/store" "/nix-store"

# delete a chunk
$ beam_rewriter ./parser.beam \
  --delete-chunk Dbgi \

# substitue string in a chunk, and delete a chunk
$ beam_rewriter ./parser.beam \
  --substitute-chunk Line "/nix/store" "/nix-store" \
  --delete-chunk Dbgi \

# specify files by a wildcard
$ beam_rewriter **/*.beam \
  --substitute-chunk Line "/nix/store" "/nix-store"

# specify files by a wildcard and multiple filenames
$ beam_rewriter *.beam lib/parser.beam lib/compiler.beam \
  --substitute-chunk Line "/nix/store" "/nix-store"
```

> In pratice, you shouldn't delete arbitrary chunks. Here is just a demonstration of how to use this program.

## References

- [6.2. The BEAM File Format of The Erlang Runtime System](https://blog.stenmans.org/theBeamBook/#BEAM_files)

## License

MIT
