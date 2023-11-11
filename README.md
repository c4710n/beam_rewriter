# beam_rewriter

Rewrite BEAM files with ease.

## Notice!

This project is still in development.

Right now, I'm stuck on the issue of "encoding/decoding chunk data". As described [here](https://blog.stenmans.org/theBeamBook/#BEAM_files), almost all the chunks have their own unique data format, but this documentation only covers a limited number of chunks, lacking the chunks what I need, such as _Line_ chunk.

Before proceeding with the development, I need to understand the data format of all the chunks. However, with my limited experience of C or Erlang, it's difficult to dig the data format. Therefore, the development is indefinitely postponed.

If you have knowledge in this area, please feel free to reach out to me.

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
